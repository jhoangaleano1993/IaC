# RBAC para Azure DevOps en EKS

Este directorio contiene los manifiestos de Kubernetes para configurar **RBAC (Role-Based Access Control)** que permite a Azure DevOps conectarse y gestionar recursos en el cluster EKS.

---

## 📋 Recursos Creados

### 1. **Namespace** (`namespace.yaml`)
- **Nombre**: `devops`
- **Propósito**: Aislar recursos de Azure DevOps

### 2. **ServiceAccount** (`serviceaccount.yaml`)
- **Nombre**: `azure-devops-sa`
- **Namespace**: `devops`
- **Propósito**: Identidad para Azure DevOps

### 3. **Role** (`role.yaml`)
- **Nombre**: `azure-devops-role`
- **Scope**: Namespace `devops`
- **Permisos**:
  - Deployments: `get`, `list`, `watch`, `create`, `update`, `patch`, `delete`
  - Pods: `get`, `list`, `watch`, `create`, `update`, `patch`, `delete`
  - Services: `get`, `list`, `watch`, `create`, `update`, `patch`, `delete`
  - ConfigMaps/Secrets: `get`, `list`, `watch`, `create`, `update`, `patch`, `delete`
  - Ingress: `get`, `list`, `watch`, `create`, `update`, `patch`, `delete`
  - HPA: `get`, `list`, `watch`, `create`, `update`, `patch`, `delete`

### 4. **RoleBinding** (`rolebinding.yaml`)
- **Nombre**: `azure-devops-rolebinding`
- **Vincula**: `azure-devops-sa` con `azure-devops-role`

### 5. **ClusterRole** (`clusterrole.yaml`)
- **Nombre**: `azure-devops-cluster-role`
- **Scope**: Todo el cluster
- **Permisos de solo lectura**:
  - Nodes: `get`, `list`, `watch`
  - Namespaces: `get`, `list`, `watch`
  - PersistentVolumes: `get`, `list`, `watch`
  - StorageClasses: `get`, `list`, `watch`
  - CRDs: `get`, `list`, `watch`

### 6. **ClusterRoleBinding** (`clusterrolebinding.yaml`)
- **Nombre**: `azure-devops-cluster-rolebinding`
- **Vincula**: `azure-devops-sa` con `azure-devops-cluster-role`

---
