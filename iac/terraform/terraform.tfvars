aws_region = "us-east-1"

cluster_name       = "devops-eks"
kubernetes_version = "1.31"
node_instance_type = "t3.small"

environment = "dev"
vpc_name    = "devops-vpc"
vpc_cidr    = "10.60.0.0/16"

azs = ["us-east-1a", "us-east-1b"]

private_subnets = ["10.60.0.0/24", "10.60.1.0/24"]
public_subnets  = ["10.60.100.0/24", "10.60.101.0/24"]
