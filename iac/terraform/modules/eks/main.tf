module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.10.1"

  name = var.cluster_name
  kubernetes_version = var.kubernetes_version

  endpoint_public_access = true

  # Agregar permisos de acceso al cluster para identidad AWS
  enable_cluster_creator_admin_permissions = true

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  # Addons esenciales de EKS
  addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni    = {
      before_compute = true
    }
  }

  # Node Group administrado por AWS (managed node group)
  # 1 solo nodo
  eks_managed_node_groups = {
    one_node = {
      instance_types = [var.node_instance_type]

      min_size     = 1
      max_size     = 1
      desired_size = 1

      # Usar solo subnets privadas para los nodos
      subnet_ids = var.private_subnet_ids
    }
  }

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}
