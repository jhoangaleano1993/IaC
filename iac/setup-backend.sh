#!/bin/bash

# Script para configurar el backend de Terraform automáticamente
# Este script:
#   1. Crea el S3 bucket y la tabla DynamoDB
#   2. Genera el archivo backend.tf con los valores correctos
#   3. Inicializa Terraform con el backend remoto

set -e

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Directorios
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$SCRIPT_DIR/terraform-backend"
TERRAFORM_DIR="$SCRIPT_DIR/terraform"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Setup de Backend para Terraform      ${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Paso 1: Crear el backend (S3 + DynamoDB)
echo -e "${YELLOW}[1/3] Creando infraestructura del backend...${NC}"
cd "$BACKEND_DIR"

if [ ! -d ".terraform" ]; then
    echo -e "${YELLOW}Inicializando Terraform en terraform-backend...${NC}"
    terraform init
fi

echo -e "${YELLOW}Aplicando configuración del backend...${NC}"
terraform apply -auto-approve

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Backend creado exitosamente${NC}"
else
    echo -e "${RED}✗ Error al crear el backend${NC}"
    exit 1
fi

echo ""

# Paso 2: Generar backend.tf
echo -e "${YELLOW}[2/3] Generando archivo backend.tf...${NC}"
./generate-backend.sh

echo ""

# Paso 3: Inicializar Terraform con backend remoto
echo -e "${YELLOW}[3/3] Inicializando Terraform con backend remoto...${NC}"
cd "$TERRAFORM_DIR"

if [ -f "backend.tf" ]; then
    echo -e "${YELLOW}Re-inicializando Terraform con el nuevo backend...${NC}"
    terraform init -reconfigure -migrate-state
else
    echo -e "${RED}Error: No se generó el archivo backend.tf${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  ✓ Setup completado exitosamente      ${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Mostrar información del backend
S3_BUCKET=$(cd "$BACKEND_DIR" && terraform output -raw s3_bucket_id)
DYNAMODB_TABLE=$(cd "$BACKEND_DIR" && terraform output -raw dynamodb_table_name)

echo -e "${BLUE}Información del Backend:${NC}"
echo -e "  S3 Bucket: ${GREEN}$S3_BUCKET${NC}"
echo -e "  DynamoDB Table: ${GREEN}$DYNAMODB_TABLE${NC}"
echo ""

echo -e "${YELLOW}Próximos pasos:${NC}"
echo -e "  1. Revisa el plan: ${GREEN}cd terraform && terraform plan${NC}"
echo -e "  2. Aplica los cambios: ${GREEN}terraform apply${NC}"
echo ""
