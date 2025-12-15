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

## 🚀 Aplicación de Manifiestos

### Opción 1: Automático via Pipeline (Recomendado)

El pipeline de Azure DevOps aplica automáticamente todos los manifiestos RBAC después de crear el cluster EKS. No necesitas hacer nada manualmente.

Ver: `azure-pipelines.yml` → Stage Apply → Task "Setup RBAC for Azure DevOps"

### Opción 2: Manual

Si necesitas aplicar los manifiestos manualmente:

```bash
# 1. Configurar kubectl
aws eks update-kubeconfig --name devops-eks --region us-east-1

# 2. Aplicar todos los manifiestos (simple)
kubectl apply -f k8s/rbac/

# O aplicar uno por uno:
kubectl apply -f k8s/rbac/namespace.yaml
kubectl apply -f k8s/rbac/serviceaccount.yaml
kubectl apply -f k8s/rbac/role.yaml
kubectl apply -f k8s/rbac/rolebinding.yaml
kubectl apply -f k8s/rbac/clusterrole.yaml
kubectl apply -f k8s/rbac/clusterrolebinding.yaml

# 3. Crear secret para el token (K8s 1.24+)
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: azure-devops-sa-token
  namespace: devops
  annotations:
    kubernetes.io/service-account.name: azure-devops-sa
type: kubernetes.io/service-account-token
EOF

# 4. Obtener el token
kubectl get secret azure-devops-sa-token -n devops -o jsonpath='{.data.token}' | base64 --decode

# 5. Obtener el CA certificate
kubectl get secret azure-devops-sa-token -n devops -o jsonpath='{.data.ca\.crt}'

# 6. Obtener el endpoint del cluster
kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}'
```

---

## 🔐 Configurar en Azure DevOps

### Opción 1: Service Connection (Recomendado)

1. Ve a **Project Settings** → **Service connections**
2. Click **New service connection** → **Kubernetes**
3. Configura:
   - **Authentication method**: Service Account
   - **Server URL**: (endpoint del cluster)
   - **Secret**: (token del ServiceAccount)
   - **Service connection name**: `EKS-Cluster`
4. Click **Verify and save**

### Opción 2: En el Pipeline (kubectl task)

```yaml
- task: Kubernetes@1
  inputs:
    connectionType: 'Kubernetes Service Connection'
    kubernetesServiceEndpoint: 'EKS-Cluster'
    namespace: 'devops'
    command: 'apply'
    arguments: '-f deployment.yaml'
```

---

## ✅ Verificación

### Verificar que los recursos se crearon

```bash
# Verificar namespace
kubectl get namespace devops

# Verificar ServiceAccount
kubectl get serviceaccount -n devops

# Verificar Role y RoleBinding
kubectl get role,rolebinding -n devops

# Verificar ClusterRole y ClusterRoleBinding
kubectl get clusterrole azure-devops-cluster-role
kubectl get clusterrolebinding azure-devops-cluster-rolebinding

# Verificar Secret del token
kubectl get secret azure-devops-sa-token -n devops
```

### Probar permisos del ServiceAccount

```bash
# Test: Puede listar pods en namespace devops
kubectl auth can-i get pods --as=system:serviceaccount:devops:azure-devops-sa -n devops

# Test: Puede crear deployments en namespace devops
kubectl auth can-i create deployments --as=system:serviceaccount:devops:azure-devops-sa -n devops

# Test: Puede ver nodos (ClusterRole)
kubectl auth can-i get nodes --as=system:serviceaccount:devops:azure-devops-sa

# Test: NO puede crear namespaces (no tiene permisos)
kubectl auth can-i create namespaces --as=system:serviceaccount:devops:azure-devops-sa
```

Todos los comandos con permisos otorgados deberían devolver `yes`.

---

## 🔒 Seguridad

### Principio de Mínimo Privilegio

✅ **Permisos limitados al namespace `devops`**
- El Role solo otorga permisos dentro del namespace `devops`
- No puede modificar otros namespaces

✅ **Permisos de cluster en modo lectura**
- ClusterRole solo permite `get`, `list`, `watch`
- No puede crear o modificar recursos a nivel de cluster

✅ **No tiene permisos administrativos**
- No puede crear/modificar CRDs
- No puede modificar RBAC
- No puede acceder a recursos de sistema

### Rotación de Tokens

Para rotar el token del ServiceAccount:

```bash
# 1. Eliminar el secret actual
kubectl delete secret azure-devops-sa-token -n devops

# 2. Crear nuevo secret
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: azure-devops-sa-token
  namespace: devops
  annotations:
    kubernetes.io/service-account.name: azure-devops-sa
type: kubernetes.io/service-account-token
EOF

# 3. Obtener el nuevo token
kubectl get secret azure-devops-sa-token -n devops -o jsonpath='{.data.token}' | base64 --decode

# 4. Actualizar en Azure DevOps Service Connection
```

---

## 📊 Permisos Otorgados

### En Namespace `devops` (Role)

| Recurso | Permisos |
|---------|----------|
| Deployments | Full (CRUD) |
| ReplicaSets | Full (CRUD) |
| Pods | Full (CRUD) |
| Services | Full (CRUD) |
| ConfigMaps | Full (CRUD) |
| Secrets | Full (CRUD) |
| Ingress | Full (CRUD) |
| HPA | Full (CRUD) |

### A Nivel de Cluster (ClusterRole)

| Recurso | Permisos |
|---------|----------|
| Nodes | Solo lectura |
| Namespaces | Solo lectura |
| PersistentVolumes | Solo lectura |
| StorageClasses | Solo lectura |
| CRDs | Solo lectura |

---

## 🧹 Limpieza

Para eliminar todos los recursos RBAC:

```bash
# Eliminar en orden inverso
kubectl delete clusterrolebinding azure-devops-cluster-rolebinding
kubectl delete clusterrole azure-devops-cluster-role
kubectl delete rolebinding azure-devops-rolebinding -n devops
kubectl delete role azure-devops-role -n devops
kubectl delete secret azure-devops-sa-token -n devops
kubectl delete serviceaccount azure-devops-sa -n devops
kubectl delete namespace devops
```

⚠️ **Advertencia**: Esto eliminará todos los recursos en el namespace `devops`

---

## 🐛 Troubleshooting

### Error: "serviceaccounts is forbidden"

**Causa**: No tienes permisos de administrador en el cluster

**Solución**: Asegúrate de que tu AWS IAM user tenga permisos de administrador de EKS

```bash
# Verificar tu identidad actual
aws sts get-caller-identity

# Verificar permisos de kubectl
kubectl auth can-i create serviceaccount -n devops
```

### Error: "token not found" después de crear ServiceAccount

**Causa**: En Kubernetes 1.24+, los tokens no se crean automáticamente

**Solución**: Crear el Secret manualmente (ya incluido en el script)

### ServiceAccount no tiene permisos

**Verificar**:
```bash
# Ver detalles del RoleBinding
kubectl describe rolebinding azure-devops-rolebinding -n devops

# Ver detalles del Role
kubectl describe role azure-devops-role -n devops
```

---

## 📚 Referencias

- [Kubernetes RBAC Documentation](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
- [EKS User Guide - Managing Users](https://docs.aws.amazon.com/eks/latest/userguide/add-user-role.html)
- [Service Account Tokens](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/)

---

**Última actualización:** Diciembre 2025
