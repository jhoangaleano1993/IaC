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

## Paso 5: Configurar en Azure DevOps

1. En Azure DevOps → **Pipelines** → **Library**
2. Click en **+ Variable group**
3. Nombre: `AWS-Credentials`
4. Agrega las variables:

   **Variable 1:**
   - Name: `AWS_ACCESS_KEY_ID`
   - Value: (pega el Access Key ID de arriba)
   - Click en el **candado 🔒** para hacerla secreta

   **Variable 2:**
   - Name: `AWS_SECRET_ACCESS_KEY`
   - Value: (pega el Secret Access Key de arriba)
   - Click en el **candado 🔒** para hacerla secreta

5. Click **Save**

## Paso 6: Verificar que funciona

Prueba que las credenciales funcionan:

```bash
# Usando AWS CLI con las credenciales del nuevo usuario
export AWS_ACCESS_KEY_ID=$(terraform output -raw access_key_id)
export AWS_SECRET_ACCESS_KEY=$(terraform output -raw secret_access_key)

# Verificar identidad
aws sts get-caller-identity

## ¿Qué hace este código?

1. **Crea un usuario IAM** en el path `/ci-cd/azure-devops-terraform`
2. **Genera Access Keys** automáticamente
3. **Crea una política IAM personalizada** con permisos para:
   - EC2 (full access)
   - EKS (full access)
   - IAM (permisos específicos para crear roles)
   - S3 (acceso al bucket de Terraform state)
   - DynamoDB (acceso a la tabla de locking)
   - CloudWatch Logs
   - Auto Scaling
   - Elastic Load Balancing

4. **Adjunta la política al usuario**

## Limpieza

⚠️ **ADVERTENCIA**: Solo elimina este usuario si ya no necesitas que Azure DevOps despliegue infraestructura.

```bash
# Primero, elimina las Access Keys manualmente
terraform destroy
```

## Troubleshooting

### Error: "User already exists"

Si el usuario ya existe, puedes importarlo:

```bash
terraform import module.azure_devops_iam.aws_iam_user.azure_devops azure-devops-terraform
```

### Error: "Bucket does not exist"

Asegúrate de haber ejecutado primero `terraform-backend/`:

```bash
cd ../terraform-backend
terraform apply
cd ../terraform-iam-user
```

### No puedo ver el Secret Access Key

El Secret Access Key solo se muestra una vez al crearlo. Si lo perdiste:

```bash
# Eliminar el access key actual
aws iam delete-access-key --user-name azure-devops-terraform --access-key-id AKIA...

# Recrear el recurso en Terraform
terraform apply -replace="module.azure_devops_iam.aws_iam_access_key.azure_devops"
``