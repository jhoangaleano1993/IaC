# Módulo de Cleanup - Limpia dependencias antes de destruir infraestructura
# Este módulo asegura que los recursos creados dinámicamente por Kubernetes
# sean eliminados antes de que Terraform intente destruir la infraestructura base.

resource "null_resource" "k8s_cleanup" {
  # Este recurso se ejecuta cuando se crea Y cuando se destruye
  triggers = {
    cluster_name = var.cluster_name
    region       = var.region
  }

  # Provisioner que se ejecuta SOLO durante el destroy
  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      #!/bin/bash
      set -e
      
      echo "============================================="
      echo "INICIANDO LIMPIEZA PRE-DESTROY"
      echo "============================================="
      
      CLUSTER_NAME="${self.triggers.cluster_name}"
      REGION="${self.triggers.region}"
      
      # Verificar si el cluster existe
      echo "Verificando si el cluster $CLUSTER_NAME existe..."
      if ! aws eks describe-cluster --name $CLUSTER_NAME --region $REGION >/dev/null 2>&1; then
        echo "Cluster no existe, saltando limpieza de Kubernetes"
        exit 0
      fi
      
      # Configurar kubectl
      echo "Configurando kubectl..."
      aws eks update-kubeconfig --name $CLUSTER_NAME --region $REGION
      
      # 1. Eliminar todos los Services tipo LoadBalancer (esto elimina los ELBs)
      echo ""
      echo "=== Paso 1: Eliminando Services LoadBalancer ==="
      for ns in $(kubectl get ns -o jsonpath='{.items[*].metadata.name}' 2>/dev/null || echo ""); do
        kubectl delete svc --all -n $ns --field-selector spec.type=LoadBalancer --ignore-not-found=true 2>/dev/null || true
      done
      
      # 2. Eliminar todos los Ingress (esto elimina ALBs si hay Ingress Controller)
      echo ""
      echo "=== Paso 2: Eliminando Ingress ==="
      kubectl delete ingress --all -A --ignore-not-found=true 2>/dev/null || true
      
      # 3. Eliminar Deployments, StatefulSets, DaemonSets (para liberar PVCs)
      echo ""
      echo "=== Paso 3: Eliminando workloads ==="
      for ns in dev qa production; do
        kubectl delete deployment --all -n $ns --ignore-not-found=true 2>/dev/null || true
        kubectl delete statefulset --all -n $ns --ignore-not-found=true 2>/dev/null || true
        kubectl delete daemonset --all -n $ns --ignore-not-found=true 2>/dev/null || true
        kubectl delete pvc --all -n $ns --ignore-not-found=true 2>/dev/null || true
      done
      
      # 4. Esperar a que los LoadBalancers se eliminen completamente
      echo ""
      echo "=== Paso 4: Esperando eliminación de LoadBalancers ==="
      for i in {1..30}; do
        LB_COUNT=$(kubectl get svc --all-namespaces -o json 2>/dev/null | grep -c '"type": "LoadBalancer"' || echo "0")
        if [ "$LB_COUNT" -eq "0" ]; then
          echo "Todos los LoadBalancers eliminados."
          break
        fi
        echo "Esperando... ($LB_COUNT LoadBalancers restantes)"
        sleep 10
      done
      
      # 5. Limpiar Security Groups huérfanos creados por K8s
      echo ""
      echo "=== Paso 5: Limpiando Security Groups huérfanos ==="
      VPC_ID=$(aws eks describe-cluster --name $CLUSTER_NAME --region $REGION --query 'cluster.resourcesVpcConfig.vpcId' --output text 2>/dev/null || echo "")
      if [ -n "$VPC_ID" ]; then
        # Buscar SGs creados por K8s (tienen tag kubernetes.io/cluster/)
        for sg in $(aws ec2 describe-security-groups --region $REGION --filters "Name=vpc-id,Values=$VPC_ID" --query "SecurityGroups[?contains(GroupName, 'k8s-elb')].GroupId" --output text 2>/dev/null || echo ""); do
          echo "Eliminando Security Group: $sg"
          aws ec2 delete-security-group --group-id $sg --region $REGION 2>/dev/null || true
        done
      fi
      
      echo ""
      echo "============================================="
      echo "LIMPIEZA PRE-DESTROY COMPLETADA"
      echo "============================================="
    EOT
    
    interpreter = ["/bin/bash", "-c"]
  }

  depends_on = []
}

# Cleanup de ECR - eliminar imágenes antes de destruir el repositorio
resource "null_resource" "ecr_cleanup" {
  triggers = {
    repository_name = var.ecr_repository_name
    region          = var.region
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      #!/bin/bash
      echo "============================================="
      echo "LIMPIANDO IMÁGENES DE ECR"
      echo "============================================="
      
      REPO_NAME="${self.triggers.repository_name}"
      REGION="${self.triggers.region}"
      
      # Verificar si el repositorio existe
      if ! aws ecr describe-repositories --repository-names $REPO_NAME --region $REGION >/dev/null 2>&1; then
        echo "Repositorio $REPO_NAME no existe, saltando limpieza"
        exit 0
      fi
      
      # Obtener todas las imágenes
      IMAGES=$(aws ecr list-images --repository-name $REPO_NAME --region $REGION --query 'imageIds[*]' --output json 2>/dev/null)
      
      if [ "$IMAGES" != "[]" ] && [ -n "$IMAGES" ]; then
        echo "Eliminando imágenes del repositorio $REPO_NAME..."
        aws ecr batch-delete-image --repository-name $REPO_NAME --region $REGION --image-ids "$IMAGES" >/dev/null 2>&1 || true
        echo "Imágenes eliminadas."
      else
        echo "No hay imágenes que eliminar."
      fi
      
      echo "============================================="
      echo "LIMPIEZA DE ECR COMPLETADA"
      echo "============================================="
    EOT
    
    interpreter = ["/bin/bash", "-c"]
  }
}
