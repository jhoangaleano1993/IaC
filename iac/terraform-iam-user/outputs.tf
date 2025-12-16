output "user_name" {
  description = "Nombre del usuario IAM creado"
  value       = module.azure_devops_iam.user_name
}

output "user_arn" {
  description = "ARN del usuario IAM"
  value       = module.azure_devops_iam.user_arn
}

output "access_key_id" {
  description = "Access Key ID para Azure DevOps"
  value       = module.azure_devops_iam.access_key_id
  sensitive   = true
}

output "secret_access_key" {
  description = "Secret Access Key para Azure DevOps"
  value       = module.azure_devops_iam.secret_access_key
  sensitive   = true
}

output "setup_instructions" {
  description = "Instrucciones para configurar las credenciales en Azure DevOps"
  value       = module.azure_devops_iam.instructions
}
