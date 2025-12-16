variable "repository_name" {
  description = "Nombre del repositorio ECR"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, qa, production)"
  type        = string
}

variable "image_tag_mutability" {
  description = "Mutabilidad de tags (MUTABLE o IMMUTABLE)"
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Habilitar escaneo de vulnerabilidades al hacer push"
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "Tipo de encriptación (AES256 o KMS)"
  type        = string
  default     = "AES256"
}

variable "kms_key_arn" {
  description = "ARN de la llave KMS (solo si encryption_type = KMS)"
  type        = string
  default     = null
}

variable "enable_lifecycle_policy" {
  description = "Habilitar política de ciclo de vida"
  type        = bool
  default     = true
}

variable "max_image_count" {
  description = "Número máximo de imágenes a mantener"
  type        = number
  default     = 10
}

variable "untagged_days" {
  description = "Días para mantener imágenes sin tag"
  type        = number
  default     = 7
}

variable "repository_policy" {
  description = "Política JSON del repositorio ECR"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags adicionales para el repositorio"
  type        = map(string)
  default     = {}
}
