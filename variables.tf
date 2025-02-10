variable kubernetes_endpoint {
  default     =  "https://kubernetes.docker.internal:6443"
  type        = string
  description = "Kubernetes/Openshift Endpoint" 
}

variable vault_address {
  type        = string
  description = "Vault Address e.g https://vault.example.com:8200" 
}

variable vault_namespace {
  type        = string
  description = "Vault Namespace" 
}

variable vault_token {
  type        = string
  description = "Vault Token" 
}

variable kubernetes_namespace {
  type        = string
  default     = "default"
  description = "Kubernetes namespace name to use" 
}

# Promethues Stack Helm Version
variable "prom_version" {
  type = string
  description = "Prom Version"
  default = "68.4.0"
}








