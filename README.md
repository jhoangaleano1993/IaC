# PruebaTecnicaDevops
Prueba técnica enfocada en IaC, CI/CD, Kubernetes, GitOps, Bash y AWS

---

### 🔹 `iac/`

Almacena la infraestructura como código encargada de **provisionar el clúster de Kubernetes en AWS (EKS)** utilizando **Terraform**.

Incluye:
- **terraform-backend/**: Infraestructura del backend remoto (S3 + DynamoDB)
  - S3 bucket para almacenar el estado de Terraform
  - Tabla DynamoDB para state locking
  - Script `generate-backend.sh` para configuración automática
- **terraform/**: Infraestructura principal
  - Definición del clúster EKS con addons (vpc-cni, kube-proxy, coredns)
  - Configuración de VPC, subredes y grupos de seguridad
  - Roles y políticas IAM necesarias
  - Node Groups para los nodos de Kubernetes
- **setup-backend.sh**: Script de configuración automática del backend
- **azure-pipelines.yml**: Pipeline de CI/CD para Azure DevOps

**Responsabilidad:** Provisionamiento de infraestructura en AWS.

**Setup rápido**:
```bash
cd iac
./setup-backend.sh  # Configura el backend remoto
cd terraform
terraform plan      # Revisa los cambios
terraform apply     # Despliega la infraestructura
```