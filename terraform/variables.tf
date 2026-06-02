variable "location" {
  description = "Azure region."
  type        = string
  default     = "eastus"
}

variable "cluster_name" {
  description = "AKS cluster name."
  type        = string
  default     = "adp-az-dev"
}

variable "kubernetes_version" {
  description = "AKS Kubernetes version."
  type        = string
  default     = "1.33"
}

variable "node_vm_size" {
  description = "VM size for the AKS node pool."
  type        = string
  default     = "Standard_D2s_v3"
}

variable "node_count" {
  description = "Number of nodes in the default pool."
  type        = number
  default     = 2
}
