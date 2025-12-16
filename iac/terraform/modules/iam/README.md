# Módulo IAM para Azure DevOps

Este módulo de Terraform crea un usuario IAM en AWS con los permisos necesarios para que Azure DevOps pueda gestionar la infraestructura de Terraform.

## ¿Qué hace este módulo?

1. **Crea un usuario IAM** llamado `azure-devops-terraform`
2. **Genera Access Keys** (Access Key ID y Secret Access Key)
3. **Asigna una política personalizada** con los permisos mínimos necesarios para:
   - Gestionar recursos EC2 (VPC, subnets, security groups, etc.)
   - Gestionar clusters EKS
   - Gestionar roles y políticas IAM
   - Acceder al bucket S3 del backend de Terraform
   - Acceder a la tabla DynamoDB para state locking
   - Crear logs en CloudWatch
   - Gestionar Auto Scaling Groups
   - Gestionar Load Balancers

## Permisos otorgados

La política IAM incluye permisos para:

- **EC2**: Acceso completo (`ec2:*`)
- **EKS**: Acceso completo (`eks:*`)
- **IAM**: Permisos específicos para crear/gestionar roles y políticas
- **S3**: Acceso al bucket de Terraform state
- **DynamoDB**: Acceso a la tabla de state locking
- **CloudWatch Logs**: Crear y gestionar logs
- **Auto Scaling**: Acceso completo
- **ELB**: Acceso completo

## Uso

El módulo ya está integrado en el `main.tf` principal:

```hcl
module "azure_devops_iam" {
  source = "./modules/iam"

  user_name              = var.azure_devops_user_name
  environment            = var.environment
  terraform_state_bucket = var.backend_s3_bucket
  terraform_lock_table   = var.backend_dynamodb_table
}
```

## Paso 1: Desplegar la infraestructura

```bash
cd iac/terraform

# Inicializar Terraform
terraform init

# Ver el plan
terraform plan

# Aplicar los cambios
terraform apply
```

## Paso 2: Obtener las credenciales

Después de ejecutar `terraform apply`, obtén las credenciales:

```bash
# Ver las instrucciones
terraform output azure_devops_setup_instructions

# Obtener el Access Key ID
terraform output -raw azure_devops_access_key_id

# Obtener el Secret Access Key
terraform output -raw azure_devops_secret_access_key
```

## Variables

| Variable | Descripción | Default |
|----------|-------------|---------|
| `user_name` | Nombre del usuario IAM | `azure-devops-terraform` |
| `environment` | Ambiente (dev, qa, prod) | - |
| `terraform_state_bucket` | Bucket S3 del backend | - |
| `terraform_lock_table` | Tabla DynamoDB de locking | - |

## Outputs

| Output | Descripción | Sensitive |
|--------|-------------|-----------|
| `user_name` | Nombre del usuario creado | No |
| `user_arn` | ARN del usuario | No |
| `access_key_id` | Access Key ID | Sí |
| `secret_access_key` | Secret Access Key | Sí |
| `instructions` | Instrucciones de configuración | No |


## Limpieza

Para eliminar el usuario IAM:

```bash
# Primero, elimina manualmente las Access Keys en la consola de AWS
# o usa AWS CLI:
aws iam delete-access-key --user-name azure-devops-terraform --access-key-id AKIA...

# Luego destruye el módulo
terraform destroy -target=module.azure_devops_iam
```
