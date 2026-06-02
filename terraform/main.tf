locals {
  tags = {
    project    = "azure-developer-platform"
    owner      = "jordann6"
    managed_by = "terraform"
  }
}

data "azurerm_client_config" "current" {}

# --- Resource groups ----------------------------------------------------------

resource "azurerm_resource_group" "platform" {
  name     = "rg-${var.cluster_name}"
  location = var.location
  tags     = local.tags
}

# Where Crossplane provisions self-service storage accounts.
resource "azurerm_resource_group" "workloads" {
  name     = "rg-adp-az-workloads"
  location = var.location
  tags     = local.tags
}

# --- AKS cluster (OIDC + workload identity) -----------------------------------

resource "azurerm_kubernetes_cluster" "this" {
  name                      = var.cluster_name
  location                  = azurerm_resource_group.platform.location
  resource_group_name       = azurerm_resource_group.platform.name
  dns_prefix                = var.cluster_name
  kubernetes_version        = var.kubernetes_version
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = var.node_vm_size
  }

  identity {
    type = "SystemAssigned"
  }

  tags = local.tags
}

# --- Workload identity for the Crossplane Azure provider ----------------------
# User-assigned identity + federated credential bound to the provider's pinned
# ServiceAccount (crossplane-system/provider-azure). No client secrets.

resource "azurerm_user_assigned_identity" "crossplane" {
  name                = "id-${var.cluster_name}-crossplane"
  location            = azurerm_resource_group.platform.location
  resource_group_name = azurerm_resource_group.platform.name
  tags                = local.tags
}

resource "azurerm_federated_identity_credential" "crossplane" {
  name                = "crossplane-provider-azure"
  resource_group_name = azurerm_resource_group.platform.name
  parent_id           = azurerm_user_assigned_identity.crossplane.id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.this.oidc_issuer_url
  subject             = "system:serviceaccount:crossplane-system:provider-azure"
}

# Least-privilege: the identity can manage resources only in the workloads RG.
resource "azurerm_role_assignment" "crossplane_workloads" {
  scope                = azurerm_resource_group.workloads.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.crossplane.principal_id
}
