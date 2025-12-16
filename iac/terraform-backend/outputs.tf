output "s3_bucket_id" {
  description = "ID del bucket S3 para el estado de Terraform"
  value       = aws_s3_bucket.terraform_state.id
}

output "s3_bucket_arn" {
  description = "ARN del bucket S3 para el estado de Terraform"
  value       = aws_s3_bucket.terraform_state.arn
}

output "dynamodb_table_name" {
  description = "Nombre de la tabla DynamoDB para state locking"
  value       = aws_dynamodb_table.terraform_locks.name
}

output "dynamodb_table_arn" {
  description = "ARN de la tabla DynamoDB para state locking"
  value       = aws_dynamodb_table.terraform_locks.arn
}
