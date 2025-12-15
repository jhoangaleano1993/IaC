variable "aws_region" {
  type        = string
  description = "Región de AWS"
  default     = "us-east-1"
}

variable "user_name" {
  type        = string
  description = "Nombre del usuario IAM para Azure DevOps"
  default     = "azure-devops-terraform"
}

variable "environment" {
  type        = string
  description = "Ambiente (dev, qa, prod)"
  default     = "dev"
}

variable "terraform_state_bucket" {
  type        = string
  description = "Nombre del bucket S3 para el estado de Terraform (debe existir)"
  default     = "tfstate-devops-289997607932"
}

variable "terraform_lock_table" {
  type        = string
  description = "Nombre de la tabla DynamoDB para state locking (debe existir)"
  default     = "terraform-state-lock"
}
