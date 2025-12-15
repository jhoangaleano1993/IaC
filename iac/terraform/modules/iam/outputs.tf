output "user_name" {
  description = "Nombre del usuario IAM creado"
  value       = aws_iam_user.azure_devops.name
}

output "user_arn" {
  description = "ARN del usuario IAM"
  value       = aws_iam_user.azure_devops.arn
}

output "access_key_id" {
  description = "Access Key ID para Azure DevOps (guardar en lugar seguro)"
  value       = aws_iam_access_key.azure_devops.id
  sensitive   = true
}

output "secret_access_key" {
  description = "Secret Access Key para Azure DevOps (guardar en lugar seguro)"
  value       = aws_iam_access_key.azure_devops.secret
  sensitive   = true
}

output "instructions" {
  description = "Instrucciones para configurar las credenciales en Azure DevOps"
  value       = <<-EOT
    ================================================================================
    CREDENCIALES GENERADAS PARA AZURE DEVOPS
    ================================================================================

    Para ver las credenciales, ejecuta:

      terraform output access_key_id
      terraform output -raw secret_access_key

    Configura estas credenciales en Azure DevOps:

    1. Ve a Pipelines > Library > Variable groups
    2. Crea un nuevo grupo llamado "AWS-Credentials"
    3. Agrega estas variables (marca el candado 🔒 para hacerlas secretas):
       - AWS_ACCESS_KEY_ID: (ejecuta: terraform output -raw access_key_id)
       - AWS_SECRET_ACCESS_KEY: (ejecuta: terraform output -raw secret_access_key)
    4. Guarda el variable group

    ⚠️  IMPORTANTE: Guarda estas credenciales de forma segura. El Secret Access Key
                    solo se muestra al crear el usuario y no se puede recuperar después.

    ================================================================================
  EOT
}
