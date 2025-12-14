# PruebaTecnicaDevops
Prueba técnica enfocada en IaC, CI/CD, Kubernetes, GitOps, Bash y AWS

## 📌 Descripción General

Este repositorio contiene la implementación de una prueba técnica DevOps cuyo objetivo es evaluar la capacidad para diseñar, desplegar y automatizar una aplicación en un entorno controlado utilizando **Kubernetes**, **Infraestructura como Código (IaC)**, **CI/CD en Azure DevOps**, **Git Flow**, **scripting en Bash** y **servicios de AWS**.

La solución está diseñada siguiendo buenas prácticas de **automatización**, **versionamiento**, **despliegue continuo** y **arquitectura Cloud Native**.  
En esta etapa, el presente documento describe **la estructura del repositorio y el propósito de cada directorio**, permitiendo una comprensión clara del proyecto.

---

## 📂 Estructura del Repositorio

├── app/
├── aws/
├── docs/
├── iac/
├── k8s/
├── pipelines/
├── scripts/
├── .gitignore
└── README.md



---

## 📁 Descripción de Directorios

### 🔹 `app/`

Contiene el código fuente de la aplicación web básica **“Hola Mundo”**, implementada utilizando **Nginx** como servidor web.

Incluye:
- Archivos estáticos de la aplicación (HTML/CSS).
- `Dockerfile` para la construcción de la imagen Docker.
- Archivos de configuración para pruebas unitarias (si aplica).
- Configuración para análisis de calidad de código con **SonarQube/SonarCloud**.

**Responsabilidad:** Aplicación y contenedorización.

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

Ver documentación detallada en:
- [docs/BACKEND_SETUP.md](docs/BACKEND_SETUP.md) - Configuración del backend
- [docs/AZURE_DEVOPS_SETUP.md](docs/AZURE_DEVOPS_SETUP.md) - Pipeline de Azure DevOps

---

### 🔹 `k8s/`

Contiene los manifiestos de **Kubernetes** necesarios para desplegar la aplicación dentro del clúster EKS.

Incluye:
- `Deployment` de la aplicación.
- `Service` para la exposición interna o externa.
- `Ingress` (opcional) para acceso HTTP.
- Configuraciones separadas por entorno (desarrollo / producción), si aplica.

**Responsabilidad:** Despliegue y operación de la aplicación en Kubernetes.

---

### 🔹 `pipelines/`

Contiene las definiciones de los **pipelines de Azure DevOps** encargados del proceso de **CI/CD**.

Incluye:
- Pipeline principal (`azure-pipelines.yml`).
- Variables por entorno (dev / prod).
- Referencias a plantillas reutilizables (**shared libraries**) ubicadas en un repositorio separado.

El pipeline se encarga de:
- Build y pruebas.
- Análisis de calidad.
- Construcción y publicación de imágenes Docker.
- Despliegue automático en Kubernetes.
- Pruebas de conectividad.

**Responsabilidad:** Automatización CI/CD.

---

### 🔹 `scripts/`

Incluye scripts en **Bash** para tareas de automatización operativa y monitoreo.

Incluye:
- Verificación del estado de los pods en Kubernetes.
- Re-despliegue automático si la aplicación no está corriendo.
- Ejecución programada mediante `cron`.
- Integración con servicios de AWS (SNS y S3).

**Responsabilidad:** Operación, monitoreo y auto-recuperación.

---

### 🔹 `aws/`

Agrupa configuraciones y scripts relacionados con **servicios de AWS** utilizados en la prueba.

Incluye:
- Creación y configuración de **SNS** para envío de alertas.
- Creación y uso de **S3** para almacenamiento de logs.
- Scripts auxiliares utilizando AWS CLI.

**Responsabilidad:** Servicios de soporte y alertamiento en AWS.

---

### 🔹 `docs/`

Contiene la documentación adicional del proyecto.

Incluye:
- Diagramas de arquitectura.
- Diagrama del flujo Git (Git Flow).
- Evidencias y capturas de pantalla.
- Decisiones técnicas y notas relevantes.

**Responsabilidad:** Documentación y evidencia técnica.

---

## 🧭 Buenas Prácticas Aplicadas

- Infraestructura definida como código (Terraform y Kubernetes).
- Separación clara de responsabilidades por directorio.
- Pipelines CI/CD desacoplados y reutilizables.
- Automatización operativa mediante scripts Bash.
- Versionamiento con Git Flow y etiquetas semánticas.
- Documentación clara y orientada a evaluación técnica.

---

## 📌 Estado Actual

- ✔ Estructura del repositorio definida  
- ✔ Documentación base creada  
- ⏳ Implementación progresiva de IaC, CI/CD y automatizaciones  

---

## 📎 Notas Finales

Este repositorio está diseñado para ser **reproducible, auditable y fácilmente extensible**, cumpliendo con los requisitos de la prueba técnica y alineado con prácticas modernas de DevOps y Cloud Computing.
