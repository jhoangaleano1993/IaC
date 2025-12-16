# Crear Usuario IAM para Azure DevOps

Este directorio contiene la configuración para crear el **usuario IAM** que Azure DevOps usará para autenticarse en AWS y desplegar la infraestructura.

## ⚠️ IMPORTANTE

Este código se ejecuta **UNA SOLA VEZ** de forma **MANUAL** con tus credenciales personales de AWS, **ANTES** de configurar el pipeline de Azure DevOps.

## Flujo de Trabajo

```
1. terraform-backend/     → Crear S3 + DynamoDB (una vez, manual)
2. terraform-iam-user/    → Crear usuario IAM (una vez, manual) 
3. Azure DevOps           → Configurar credenciales del usuario IAM
4. terraform/             → Desplegar EKS (desde Azure DevOps pipeline)
```

## Prerrequisitos

✅ Ya debes haber ejecutado `terraform-backend/` para crear:
- Bucket S3: `tfstate-devops-289997607932`
- Tabla DynamoDB: `terraform-state-lock`

✅ Debes tener configuradas tus credenciales AWS locales:
```bash
aws configure
# O tener configuradas las variables de entorno:
# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY
```

## Paso 1: Inicializar Terraform

```bash
cd iac/terraform-iam-user

# Inicializar Terraform
terraform init
```

## Paso 2: Revisar el plan

```bash
# Ver qué se va a crear
terraform plan
```

Deberías ver que se creará:
- ✅ Usuario IAM: `azure-devops-terraform`
- ✅ Access Key para el usuario
- ✅ Política IAM con permisos necesarios
- ✅ Adjuntar la política al usuario

## Paso 3: Crear el usuario

```bash
# Aplicar la configuración
terraform apply
```

## Paso 4: Obtener las credenciales

```bash
# Ver las instrucciones
terraform output setup_instructions

# Copiar el Access Key ID
terraform output -raw access_key_id

# Copiar el Secret Access Key
terraform output -raw secret_access_key
```
