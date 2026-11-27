output "cluster_context" {
  description = "Contexto Kind onde o banco foi aplicado."
  value       = var.cluster_context
}

output "database_service" {
  description = "Service Kubernetes usado pela aplicação para acessar o MySQL."
  value       = "oficina-db-svc.${var.namespace}.svc.cluster.local:3306"
}

output "database_deployment" {
  description = "Deployment do MySQL aguardado pelo Terraform."
  value       = "oficina-db"
}
