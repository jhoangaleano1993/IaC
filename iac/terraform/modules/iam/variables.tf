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
  description = "Nombre del bucket S3 donde se almacena el estado de Terraform"
}

variable "terraform_lock_table" {
  type        = string
  description = "Nombre de la tabla DynamoDB para state locking"
}
