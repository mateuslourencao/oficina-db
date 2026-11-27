variable "cluster_context" {
  description = "Contexto kubectl do cluster Kind já provisionado pelo repositório oficina-k8s-infra."
  type        = string
  default     = "kind-oficina-local"
}

variable "namespace" {
  description = "Namespace Kubernetes dos recursos do banco."
  type        = string
  default     = "default"
}

variable "deployment_timeout" {
  description = "Prazo máximo de espera pela disponibilidade do banco."
  type        = string
  default     = "180s"
}
