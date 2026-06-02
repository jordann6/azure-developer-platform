output "cluster_name" {
  value = azurerm_kubernetes_cluster.this.name
}

output "resource_group_name" {
  value = azurerm_resource_group.platform.name
}

output "workloads_resource_group" {
  description = "Resource group where Crossplane provisions self-service storage."
  value       = azurerm_resource_group.workloads.name
}

output "configure_kubectl" {
  value = "az aks get-credentials --resource-group ${azurerm_resource_group.platform.name} --name ${azurerm_kubernetes_cluster.this.name} --overwrite-existing"
}

output "crossplane_identity_client_id" {
  description = "Client ID the Crossplane provider uses via workload identity."
  value       = azurerm_user_assigned_identity.crossplane.client_id
}

output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}

output "subscription_id" {
  value = data.azurerm_client_config.current.subscription_id
}

output "oidc_issuer_url" {
  value = azurerm_kubernetes_cluster.this.oidc_issuer_url
}
