# Este archivo fue generado automáticamente por generate-backend.sh
# No editar manualmente - se sobrescribirá en la próxima ejecución
#
# Para regenerar este archivo, ejecuta:
#   cd iac/terraform-backend && ./generate-backend.sh

terraform {
  backend "s3" {
    bucket         = "tfstate-devops-289997607932"
    key            = "eks-cluster.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
