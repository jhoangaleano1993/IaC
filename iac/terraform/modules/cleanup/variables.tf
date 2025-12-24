variable "cluster_name" {
  description = "Nombre del cluster EKS"
  type        = string
}

variable "region" {
  description = "Región de AWS"
  type        = string
}

variable "ecr_repository_name" {
  description = "Nombre del repositorio ECR"
  type        = string
}
