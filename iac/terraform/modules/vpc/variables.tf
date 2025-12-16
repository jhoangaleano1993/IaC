
variable "vpc_name" {
  type        = string
  description = "Nombre de la VPC"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR de la VPC"
}

variable "azs" {
  type        = list(string)
  description = "Availability Zones"
}

variable "environment" {
  type        = string
  description = "Ambiente (dev, qa, prod)"
}

variable "cluster_name" {
  type        = string
  description = "Nombre del cluster EKS"
}

variable "private_subnets" {
  type        = list(string)
  description = "CIDRs de las subnets privadas"
}

variable "public_subnets" {
  type        = list(string)
  description = "CIDRs de las subnets públicas"
}