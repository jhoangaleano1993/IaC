# Terraform Backend - S3 y DynamoDB

Este directorio contiene la infraestructura para el backend remoto de Terraform, que incluye:
- **S3 Bucket**: Para almacenar el estado de Terraform de forma segura
- **DynamoDB Table**: Para el locking del estado de Terraform

## Importante

Este módulo debe ejecutarse **UNA SOLA VEZ** antes de configurar el backend remoto en el proyecto principal. El backend de este módulo es **local** porque no puede usar un backend remoto que aún no existe.

## Setup Automático (Recomendado)

La forma más fácil es usar el script automatizado:

```bash
cd ~/Documents/Test/PruebaTecnicaDevops/iac
./setup-backend.sh
```

Este script hace todo automáticamente:
1. Crea el S3 bucket y la tabla DynamoDB
2. Genera el archivo `backend.tf` con los valores correctos
3. Inicializa Terraform con el backend remoto

## Setup Manual

### Paso 1: Crear el Backend

```bash
cd ~/Documents/Test/PruebaTecnicaDevops/iac/terraform-backend

# Inicializar Terraform
terraform init

# Ver el plan de ejecución
terraform plan

# Aplicar la configuración
terraform apply
```

Esto creará:
- S3 Bucket: `tfstate-bucket-devops`
- DynamoDB Table: `terraform-state-lock`

## Paso 2: Configurar el Backend en el Proyecto Principal

Una vez creado el S3 bucket y la tabla DynamoDB, actualiza el archivo `backend.tf` en el directorio principal (`iac/terraform/`) con:

```hcl
terraform {
  backend "s3" {
    bucket         = "tfstate-bucket-devops"
    key            = "eks-cluster.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

## Paso 3: Migrar el Estado Local al Remoto

```bash
cd ~/Documents/Test/PruebaTecnicaDevops/iac/terraform

# Re-inicializar Terraform con el nuevo backend
terraform init -migrate-state

# Confirmar la migración cuando se solicite
```

## Características de Seguridad

### S3 Bucket
- ✅ Versionado habilitado: Permite recuperar versiones anteriores del estado
- ✅ Encriptación AES256: Los datos se almacenan encriptados
- ✅ Acceso público bloqueado: El bucket no es accesible públicamente
- ✅ Política de solo HTTPS: Fuerza el uso de conexiones seguras
- ✅ Logging habilitado: Registra todos los accesos al bucket

### DynamoDB Table
- ✅ Billing mode PAY_PER_REQUEST: Solo pagas por lo que usas
- ✅ State locking: Previene modificaciones concurrentes del estado

## Destruir el Backend

⚠️ **ADVERTENCIA**: Solo destruye el backend si estás seguro de que ya no necesitas el estado de Terraform almacenado.

```bash
# Primero, descarga el estado desde S3 si quieres conservarlo
aws s3 cp s3://tfstate-bucket-devops/eks-cluster.tfstate ./backup-state.tfstate

# Luego destruye los recursos
terraform destroy
```

## Troubleshooting

### Error: "bucket already exists"
Si el bucket ya existe, puedes importarlo:
```bash
terraform import aws_s3_bucket.terraform_state tfstate-bucket-devops
```

### Error: "table already exists"
Si la tabla DynamoDB ya existe, puedes importarla:
```bash
terraform import aws_dynamodb_table.terraform_locks terraform-state-lock
```

## Referencias

- [Terraform S3 Backend](https://www.terraform.io/language/settings/backends/s3)
- [AWS S3 Best Practices](https://docs.aws.amazon.com/AmazonS3/latest/userguide/security-best-practices.html)
- [DynamoDB State Locking](https://www.terraform.io/language/settings/backends/s3#dynamodb-state-locking)
