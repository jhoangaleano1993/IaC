# Módulo de Cleanup - DEBE ejecutarse PRIMERO durante destroy
# Terraform destruye en orden inverso a las dependencias, así que este módulo
# se destruirá ANTES que EKS, VPC y ECR, limpiando las dependencias dinámicas.
module "cleanup" {
  source = "./modules/cleanup"

  cluster_name        = var.cluster_name
  region              = var.aws_region
  ecr_repository_name = "app-hola-mundo"

  # Dependencias: cleanup depende de EKS y ECR para que durante DESTROY
  # se ejecute ANTES de destruirlos (orden inverso)
  depends_on = [module.eks, module.ecr]
}

module "vpc" {
  source = "./modules/vpc"

  cluster_name = var.cluster_name
  environment  = var.environment

  vpc_name        = var.vpc_name
  vpc_cidr        = var.vpc_cidr
  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
}

module "eks" {
  source = "./modules/eks"

  cluster_name       = var.cluster_name
  kubernetes_version = var.kubernetes_version
  node_instance_type = var.node_instance_type
  environment        = var.environment

  vpc_id = module.vpc.vpc_id
  # EKS control plane puede usar subnets públicas y privadas
  subnet_ids = concat(module.vpc.private_subnets, module.vpc.public_subnets)
  # Node groups deben usar solo subnets privadas (con NAT Gateway)
  private_subnet_ids = module.vpc.private_subnets
}

# Módulo ECR - Repositorio para imágenes Docker
module "ecr" {
  source = "./modules/ecr"

  repository_name         = "app-hola-mundo"
  environment             = var.environment
  image_tag_mutability    = "MUTABLE"
  scan_on_push            = true
  enable_lifecycle_policy = true
  max_image_count         = 10
  untagged_days           = 7

  tags = {
    Project = "AppHolaMundo"
  }
}
