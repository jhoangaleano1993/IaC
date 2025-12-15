variable "aws_region" {
  type        = string
  description = "Región AWS "
}

variable "cluster_name" {
  type        = string
  description = "Nombre del cluster EKS"
}


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

variable "private_subnets" {
  type        = list(string)
  description = "CIDRs de subnets privadas"
}

variable "public_subnets" {
  type        = list(string)
  description = "CIDRs de subnets públicas"
}

variable "environment" {
  type        = string
  description = "Ambiente (dev, qa, prod)"
}

variable "kubernetes_version" {
  type = string
}

variable "node_instance_type" {
  type = string
}
