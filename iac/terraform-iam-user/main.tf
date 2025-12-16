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

  # Backend local porque este código se ejecuta UNA VEZ de forma manual
  # No necesita backend remoto
  backend "local" {
    path = "terraform.tfstate"
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
