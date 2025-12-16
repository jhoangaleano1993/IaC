# Configuración para crear usuario IAM de Azure DevOps
# Este directorio contiene tareas GLOBALES que se ejecutan UNA SOLA VEZ localmente
#
# Propósito: Crear el usuario IAM que Azure DevOps usará para desplegar infraestructura
#
# IMPORTANTE: Ejecutar esto con TUS credenciales personales de AWS, ANTES de configurar
# el pipeline de Azure DevOps.

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Backend remoto en S3 para persistencia y compartir estado
  # Importante: el tfstate contiene las access keys del usuario IAM en texto plano
  backend "s3" {
    bucket         = "tfstate-devops-289997607932"
    key            = "iam-user.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}

# Usar el módulo IAM que creamos
module "azure_devops_iam" {
  source = "../terraform/modules/iam"

  user_name              = var.user_name
  environment            = var.environment
  terraform_state_bucket = var.terraform_state_bucket
  terraform_lock_table   = var.terraform_lock_table
}
