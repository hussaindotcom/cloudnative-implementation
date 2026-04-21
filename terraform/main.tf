# variables from providers.tf
variable "docker_username" {
  description = "Docker Hub username for pulling images"
  type        = string
  default     = "husen22"
}

variable "frontend_image" {
  description = "Frontend Docker image"
  type        = string
  default     = "husen22/emumba-frontend:latest"
}

variable "api_image" {
  description = "API Docker image"
  type        = string
  default     = "husen22/emumba-api:latest"
}

variable "mongodb_image" {
  description = "MongoDB Docker image"
  type        = string
  default     = "bitnamilegacy/mongodb:4.4.1"
}

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
  default     = "todo"
}

# Local values
locals {
  manifests_path = "${path.module}/../k8s/manifests"
}

# Output the manifests path for reference
output "manifests_path" {
  description = "Path to Kubernetes YAML manifests"
  value       = local.manifests_path
}

output "namespace" {
  description = "Kubernetes namespace"
  value       = var.namespace
}