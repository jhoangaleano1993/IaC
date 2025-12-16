output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

# ECR Outputs
output "ecr_repository_url" {
  description = "URL completa del repositorio ECR para app-hola-mundo"
  value       = module.ecr.repository_url
}

output "ecr_repository_name" {
  description = "Nombre del repositorio ECR"
  value       = module.ecr.repository_name
}

output "ecr_registry_id" {
  description = "Registry ID (AWS Account ID)"
  value       = module.ecr.registry_id
}