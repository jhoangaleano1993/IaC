output "cleanup_id" {
  description = "ID del recurso de cleanup (para establecer dependencias)"
  value       = null_resource.k8s_cleanup.id
}

output "ecr_cleanup_id" {
  description = "ID del recurso de cleanup de ECR"
  value       = null_resource.ecr_cleanup.id
}
