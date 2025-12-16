output "repository_arn" {
  description = "ARN del repositorio ECR"
  value       = aws_ecr_repository.this.arn
}

output "repository_name" {
  description = "Nombre del repositorio ECR"
  value       = aws_ecr_repository.this.name
}

output "repository_url" {
  description = "URL completa del repositorio ECR"
  value       = aws_ecr_repository.this.repository_url
}

output "registry_id" {
  description = "Registry ID (Account ID de AWS)"
  value       = aws_ecr_repository.this.registry_id
}

output "repository_uri" {
  description = "URI del repositorio para docker push/pull"
  value       = "${aws_ecr_repository.this.repository_url}"
}
