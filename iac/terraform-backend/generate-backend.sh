#!/bin/bash

# Script para generar automáticamente el archivo backend.tf con los datos correctos
# Este script lee los outputs del terraform-backend y genera el backend.tf para el proyecto principal

set -e

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}===== Generando configuración de backend =====${NC}"

# Directorio actual
BACKEND_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$BACKEND_DIR/../terraform"

# Verificar que estamos en el directorio correcto
if [ ! -f "$BACKEND_DIR/main.tf" ]; then
    echo -e "${RED}Error: No se encontró main.tf en el directorio actual${NC}"
    exit 1
fi

# Obtener outputs de Terraform
echo -e "${YELLOW}Obteniendo información del backend...${NC}"

# Verificar si el estado existe
if [ ! -f "$BACKEND_DIR/terraform.tfstate" ]; then
    echo -e "${RED}Error: No se encontró terraform.tfstate${NC}"
    echo -e "${RED}Primero debes ejecutar 'terraform apply' en este directorio${NC}"
    exit 1
fi

# Obtener valores de los outputs
S3_BUCKET=$(terraform output -raw s3_bucket_id 2>/dev/null)
DYNAMODB_TABLE=$(terraform output -raw dynamodb_table_name 2>/dev/null)
AWS_REGION=$(terraform output -json | jq -r '.s3_bucket_arn.value' | cut -d':' -f4)

# Si no pudimos obtener la región del ARN, usar el valor por defecto
if [ -z "$AWS_REGION" ]; then
    AWS_REGION="us-east-1"
fi

# Verificar que obtuvimos los valores
if [ -z "$S3_BUCKET" ] || [ -z "$DYNAMODB_TABLE" ]; then
    echo -e "${RED}Error: No se pudieron obtener los valores de los outputs${NC}"
    echo "S3_BUCKET: $S3_BUCKET"
    echo "DYNAMODB_TABLE: $DYNAMODB_TABLE"
    exit 1
fi

echo -e "${GREEN}✓ S3 Bucket: $S3_BUCKET${NC}"
echo -e "${GREEN}✓ DynamoDB Table: $DYNAMODB_TABLE${NC}"
echo -e "${GREEN}✓ AWS Region: $AWS_REGION${NC}"

# Generar el archivo backend.tf
BACKEND_FILE="$TERRAFORM_DIR/backend.tf"

echo -e "${YELLOW}Generando archivo backend.tf...${NC}"

cat > "$BACKEND_FILE" <<EOF
# Este archivo fue generado automáticamente por generate-backend.sh
# No editar manualmente - se sobrescribirá en la próxima ejecución
#
# Para regenerar este archivo, ejecuta:
#   cd iac/terraform-backend && ./generate-backend.sh

terraform {
  backend "s3" {
    bucket         = "$S3_BUCKET"
    key            = "eks-cluster.tfstate"
    region         = "$AWS_REGION"
    encrypt        = true
    dynamodb_table = "$DYNAMODB_TABLE"
  }
}
EOF

echo -e "${GREEN}✓ Archivo backend.tf generado exitosamente en:${NC}"
echo -e "${GREEN}  $BACKEND_FILE${NC}"

# Mostrar el contenido generado
echo -e "\n${YELLOW}Contenido del archivo generado:${NC}"
cat "$BACKEND_FILE"

# Instrucciones para el usuario
echo -e "\n${YELLOW}===== Próximos pasos =====${NC}"
echo -e "${GREEN}1.${NC} Ve al directorio de terraform:"
echo -e "   ${YELLOW}cd $TERRAFORM_DIR${NC}"
echo -e "${GREEN}2.${NC} Inicializa Terraform con el nuevo backend:"
echo -e "   ${YELLOW}terraform init -migrate-state${NC}"
echo -e "${GREEN}3.${NC} Confirma la migración cuando se solicite"
echo ""
echo -e "${YELLOW}Nota:${NC} Si ya tienes un estado local, Terraform te preguntará si quieres migrarlo al S3."
echo ""
