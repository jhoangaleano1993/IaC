variable "aws_region" {
  type        = string
  description = "Región de AWS"
  default     = "us-east-1"
}

variable "bucket_name" {
  type        = string
  description = "Nombre del bucket S3 para el estado de Terraform"
  default     = "tfstate-devops-289997607932"
}

variable "dynamodb_table_name" {
  type        = string
  description = "Nombre de la tabla DynamoDB para state locking"
  default     = "terraform-state-lock"
}

variable "environment" {
  type        = string
  description = "Ambiente (dev, qa, prod)"
  default     = "dev"
}
