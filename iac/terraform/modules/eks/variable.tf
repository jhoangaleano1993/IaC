variable "cluster_name" {
  type = string
}

variable "kubernetes_version" {
  type = string
}

variable "node_instance_type" {
  type = string
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID donde se desplegará EKS"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnets donde se desplegará el control plane de EKS"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Subnets privadas donde se desplegarán los nodos"
}

