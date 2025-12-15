# PruebaTecnicaDevops

Prueba técnica enfocada en **IaC**, **CI/CD**, **Kubernetes**, **GitOps**, **Bash** y **AWS**

---

## 📌 Descripción General

Este repositorio contiene la implementación completa de una infraestructura de **Amazon EKS (Elastic Kubernetes Service)** desplegada mediante:

- **Infraestructura como Código (IaC)** con Terraform
- **CI/CD automatizado** con Azure DevOps Pipelines
- **Gestión de estado remoto** con S3 y DynamoDB
- **Seguridad y permisos** con IAM roles y políticas
- **Arquitectura Cloud Native** siguiendo mejores prácticas

🏷️ **Ambiente**: Development (Dev)
⚠️ **Nota**: Esta es una infraestructura de desarrollo/prueba, no para producción

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
git clone <repository-url>
cd PruebaTecnicaDevops

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

# 5. Configurar en Azure DevOps (ver documentación)
# 6. Ejecutar pipeline desde Azure DevOps
```

📖 **Documentación detallada:** [docs/SETUP_COMPLETO.md](docs/SETUP_COMPLETO.md)

---

## 📂 Estructura del Repositorio

```
PruebaTecnicaDevops/
├── azure-pipelines.yml          # Pipeline principal de Azure DevOps
├── .gitignore
├── README.md
│
├── iac/                          # Infraestructura como Código
│   ├── terraform-backend/        # Backend S3 + DynamoDB (Paso 1)
│   ├── terraform-iam-user/       # Usuario IAM para Azure DevOps (Paso 2)
│   ├── terraform/                # Infraestructura EKS (Paso 3)
│   │   └── modules/
│   │       ├── vpc/              # Módulo VPC
│   │       ├── eks/              # Módulo EKS
│   │       └── iam/              # Módulo IAM
│   └── setup-backend.sh
│
└── docs/                         # Documentación técnica
    ├── SETUP_COMPLETO.md
    ├── AWS_IAM_SETUP.md
    └── AZURE_DEVOPS_SETUP.md
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

### Flujo de Despliegue

```
┌─────────────────────────────────────────────────────────────┐
│               SETUP INICIAL (Una vez, manual)                │
└─────────────────────────────────────────────────────────────┘
                          ↓
    ┌─────────────────────────────────────────┐
    │ 1. terraform-backend/                    │
    │    Crear S3 + DynamoDB                   │
    └─────────────────────────────────────────┘
                          ↓
    ┌─────────────────────────────────────────┐
    │ 2. terraform-iam-user/                   │
    │    Crear usuario IAM                     │
    └─────────────────────────────────────────┘
                          ↓
    ┌─────────────────────────────────────────┐
    │ 3. Azure DevOps                          │
    │    Configurar Variable Group             │
    └─────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│            DESPLIEGUE CONTINUO (Azure DevOps)                │
└─────────────────────────────────────────────────────────────┘
                          ↓
    ┌─────────────────────────────────────────┐
    │ 4. terraform/                            │
    │    Desplegar VPC + EKS                   │
    │    (Automático desde pipeline)           │
    └─────────────────────────────────────────┘
```

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

### Costos Estimados

⚠️ **Importante**: Esta infraestructura genera costos en AWS

- **EKS Cluster**: ~$73/mes
- **EC2 Nodes** (t3.medium x2): ~$60/mes
- **NAT Gateways** (x3): ~$97/mes
- **Total estimado**: ~$230/mes

💡 **Ambiente de Desarrollo**: Recuerda destruir la infraestructura cuando no la uses para evitar costos innecesarios:
```bash
terraform destroy
```

---

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

---

## 📖 Documentación

### Guías Principales

- 📘 [SETUP_COMPLETO.md](docs/SETUP_COMPLETO.md) - Guía paso a paso completa
- 🔑 [AWS_IAM_SETUP.md](docs/AWS_IAM_SETUP.md) - Configuración de credenciales
- 🔄 [AZURE_DEVOPS_SETUP.md](docs/AZURE_DEVOPS_SETUP.md) - Setup del pipeline

### Por Componente

- 📦 [terraform-backend/README.md](iac/terraform-backend/README.md)
- 👤 [terraform-iam-user/README.md](iac/terraform-iam-user/README.md)
- ☁️ [modules/iam/README.md](iac/terraform/modules/iam/README.md)

---

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

⚠️ **Advertencia**: Asegúrate de hacer backup del estado antes de destruir

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

✅ **Documentación**
- README en cada componente
- Diagramas de arquitectura
- Guías paso a paso

✅ **Organización**
- Estructura clara de directorios
- Separación de responsabilidades
- Nomenclatura consistente

---

## 🐛 Troubleshooting

### Problemas Comunes

**Error: "Bucket already exists"**
```bash
terraform import aws_s3_bucket.terraform_state tfstate-devops-289997607932
```

**Error: "Access Denied" en pipeline**
- Verifica que las credenciales en Azure DevOps sean correctas
- Verifica que el usuario IAM tenga los permisos necesarios

**Error: Nodos no se registran en EKS**
- Verifica security groups
- Revisa logs de los nodos: `kubectl logs -n kube-system`

📖 Ver más en: [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)

---

## 📝 Estado del Proyecto

- ✅ Infraestructura base (VPC + EKS)
- ✅ Backend de Terraform
- ✅ Pipeline de CI/CD
- ✅ Gestión de credenciales
- ✅ Documentación completa
- ⏳ Aplicación de ejemplo (próximamente)
- ⏳ Monitoreo y alertas (próximamente)

---

## 👥 Contribución

Este es un proyecto de prueba técnica. Para sugerencias:

1. Fork el repositorio
2. Crea una rama feature (`git checkout -b feature/mejora`)
3. Commit tus cambios (`git commit -m 'Add: nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/mejora`)
5. Abre un Pull Request

---

## 📄 Licencia

Este proyecto es de uso educativo y de evaluación técnica.

---

## 📞 Soporte

Para preguntas o problemas:
- 📧 Email: [tu-email]
- 📝 Issues: [GitHub Issues]
- 📚 Documentación: [docs/](docs/)

---

**Última actualización:** Diciembre 2025
**Versión:** 1.0.0
