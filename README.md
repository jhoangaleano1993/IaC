# PruebaTecnicaDevops

Prueba técnica enfocada en **IaC**, **CI/CD**, **Kubernetes**, **GitOps**, **Bash** y **AWS**

---

## 📌 Descripción General

Este repositorio contiene la implementación completa de una infraestructura de **Amazon EKS (Elastic Kubernetes Service)** desplegada mediante:

- **Infraestructura como Código (IaC)** con Terraform
- **CI/CD automatizado** con Azure DevOps Pipelines
- **Gestión de estado remoto** con S3 y DynamoDB
- **Seguridad y permisos** con IAM roles y políticas

🏷️ **Ambiente**: Development (Dev)
 **Nota**: Esta es una infraestructura de prueba.

---

## 🚀 Quick Start

### Prerrequisitos

- AWS CLI configurado con credenciales
- Terraform >= 1.0
- Cuenta de Azure DevOps
- Git

### Despliegue Rápido

```bash
# 1. Clonar el repositorio
git clone https://github.com/jhoangaleano1993/IaC.git
cd IaC

# 2. Crear backend de Terraform (S3 + DynamoDB)
cd iac/terraform-backend
terraform init
terraform apply

# 3. Crear usuario IAM para Azure DevOps
cd ../terraform-iam-user
terraform init
terraform apply

# 4. Obtener credenciales
terraform output -raw access_key_id
terraform output -raw secret_access_key

# 5. Configurar en Azure DevOps
# 6. Ejecutar pipeline desde Azure DevOps
```

---

## 📂 Estructura del Repositorio

```
IaC/
├── azure-pipelines.yml          # Pipeline principal de Azure DevOps
├── .gitignore
├── README.md
│
├── iac/                          # Infraestructura como Código
    ├── terraform-backend/        # Backend S3 + DynamoDB 
    ├── terraform-iam-user/       # Usuario IAM para Azure DevOps 
    ├── terraform/                # Infraestructura EKS 
    │   └── modules/
    │       ├── vpc/              # Módulo VPC
    │       ├── eks/              # Módulo EKS
    │       └── iam/              # Módulo IAM
    └── setup-backend.sh


```

---

## 🏗️ Arquitectura

### Componentes Principales

#### 1. **Backend de Terraform** (`iac/terraform-backend/`)
- **S3 Bucket**: Almacenamiento del estado de Terraform
- **DynamoDB Table**: State locking para prevenir conflictos
- **Características**: Versionado, encriptación, acceso restringido

#### 2. **Gestión de Credenciales** (`iac/terraform-iam-user/`)
- **Usuario IAM**: `azure-devops-terraform`
- **Política personalizada**: Permisos mínimos necesarios
- **Access Keys**: Para autenticación de Azure DevOps

#### 3. **Infraestructura EKS** (`iac/terraform/`)
- **VPC**: Red privada virtual con subnets públicas y privadas
- **EKS Cluster**: Kubernetes gestionado versión 1.31
- **Node Groups**: Nodos t3.medium en subnets privadas
- **Addons**: vpc-cni, kube-proxy, coredns
- **NAT Gateways**: Para acceso a internet desde subnets privadas

---

## 🔧 CI/CD Pipeline

El pipeline de Azure DevOps (`azure-pipelines.yml`) automatiza:

### Stages

1. **Validate**
   - Terraform init
   - Terraform validate
   - Terraform fmt check

2. **Plan**
   - Genera plan de ejecución
   - Publica plan como artifact

3. **Apply** (solo en branch `main`)
   - Aplica cambios de infraestructura
   - Configura kubectl
   - Verifica cluster

4. **Destroy** (manual, con variable)
   - Destruye infraestructura

### Triggers

- **Branches**: `main`, `dev`
- **Paths**: Cambios en `iac/terraform/**`

---

## 📋 Recursos Creados

### AWS Resources

| Recurso | Cantidad | Descripción |
|---------|----------|-------------|
| VPC | 1 | Red virtual privada |
| Subnets | 6 | 3 públicas + 3 privadas |
| NAT Gateways | 3 | Uno por AZ |
| Internet Gateway | 1 | Acceso a internet |
| EKS Cluster | 1 | Kubernetes v1.31 |
| Node Groups | 1 | 2 nodos t3.medium |
| Security Groups | Multiple | Reglas de firewall |
| IAM Roles | Multiple | Permisos de EKS |
| S3 Bucket | 1 | Terraform state |
| DynamoDB Table | 1 | State locking |

## 🔐 Seguridad

### Implementaciones de Seguridad

✅ **Gestión de Secretos**
- Variables secretas en Azure DevOps Variable Groups
- Outputs sensibles marcados como `sensitive`
- .gitignore configurado para archivos sensibles

✅ **Backend Seguro**
- S3 con encriptación AES256
- Versionado habilitado
- Acceso público bloqueado
- DynamoDB para state locking

✅ **IAM Least Privilege**
- Políticas personalizadas con permisos mínimos
- Roles separados para EKS, nodos y pods
- Usuario IAM específico para CI/CD

✅ **Network Security**
- Nodos en subnets privadas
- Security groups restrictivos
- NAT Gateways para salida controlada


## 🛠️ Tecnologías Utilizadas

| Categoría | Tecnología | Versión |
|-----------|-----------|---------|
| IaC | Terraform | 1.13.0 |
| Cloud Provider | AWS | - |
| Kubernetes | EKS | 1.31 |
| CI/CD | Azure DevOps | - |
| SCM | Git/GitHub | - |

---

## 🧪 Verificación

### Verificar Despliegue

```bash
# 1. Configurar kubectl
aws eks update-kubeconfig --name devops-eks --region us-east-1

# 2. Verificar nodos
kubectl get nodes

# 3. Verificar addons
aws eks list-addons --cluster-name devops-eks --region us-east-1

# 4. Verificar pods del sistema
kubectl get pods -n kube-system
```

### Verificar Backend

```bash
# Verificar S3 bucket
aws s3 ls s3://tfstate-devops-289997607932/

# Verificar DynamoDB table
aws dynamodb describe-table --table-name terraform-state-lock

# Verificar usuario IAM
aws iam get-user --user-name azure-devops-terraform
```

---

## 🧹 Limpieza

Para eliminar toda la infraestructura:

```bash
# 1. Destruir EKS (desde pipeline o manualmente)
cd iac/terraform
terraform destroy

# 2. Destruir usuario IAM
cd ../terraform-iam-user
terraform destroy

# 3. Destruir backend (último paso)
cd ../terraform-backend
terraform destroy
```

---

## 🎯 Buenas Prácticas Aplicadas

✅ **Infraestructura como Código**
- Todo versionado en Git
- Módulos reutilizables
- Variables parametrizadas

✅ **CI/CD Automatizado**
- Pipeline declarativo
- Stages separados (validate, plan, apply)
- Aprobaciones manuales para producción

✅ **Seguridad**
- Principio de mínimo privilegio
- Secretos no expuestos en código
- Backend encriptado


## 📞 Soporte

Preguntas o problemas:
- 📧 Email: jhoangaleano1993@gmail.com
- 📝 Issues: [GitHub Issues](https://github.com/jhoangaleano1993/IaC/issues)

---

**Última actualización:** Diciembre 2025
**Versión:** 1.0.0
