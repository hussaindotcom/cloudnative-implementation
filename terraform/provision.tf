# Minikube provisioning
variable "minikube_version" {
  description = "Minikube version to install"
  type        = string
  default     = "v1.32.0"
}

variable "kubectl_version" {
  description = "kubectl version to install"
  type        = string
  default     = "v1.28.0"
}

# resource to check if minikube is installed or not
resource "null_resource" "check_minikube" {
  provisioner "local-exec" {
    command = <<-EOT
      if ! command -v minikube &> /dev/null; then
        echo "minikube not found"
        exit 1
      fi
      echo "minikube is installed"
    EOT
  }
}

# resource to start minikube cluster if not running
resource "null_resource" "start_minikube" {
  depends_on = [null_resource.check_minikube]
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "starting Minikube cluster..."
      minikube status || minikube start --driver=docker --cpus=2 --memory=2048
      minikube status
    EOT
  }
}

# resource to enable ingress controller for frintend access
resource "null_resource" "enable_ingress" {
  depends_on = [null_resource.start_minikube]
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "Enabling nginx Ingress controller"
      minikube addons enable ingress
    EOT
  }
}

# resource to apply k8s manifests written within the repo at ../../k8s/
resource "null_resource" "apply_manifests" {
  depends_on = [null_resource.start_minikube]
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "Applying k8s resources"
      cd ${path.module}/../k8s/manifests
      
      # to apply namespace
      kubectl apply -f namespace.yaml
      
      # to apply configmaps and secrets
      kubectl apply -f configmap.yaml
      kubectl apply -f secrets.yaml
      
      # to apply mongo sts
      kubectl apply -f mongodb.yaml
      
      # to wait for mongo to be be in ready state
      echo "Waiting for MongoDB to be ready..."
      kubectl wait --for=condition=ready pod/mongodb-0 -n todo --timeout=300s || true
      
      # to apply backend after mongo is ready
      kubectl apply -f api.yaml
      
      # to apply fronyend
      kubectl apply -f frontend.yaml
      
      # to apply network policy as per requirement
      kubectl apply -f network-policy.yaml
      
      echo "All k8s resources applied successfully"
    EOT
  }
}

# resource to print service info
resource "null_resource" "display_services" {
  depends_on = [null_resource.apply_manifests]
  
  provisioner "local-exec" {
    command = <<-EOT
      echo ""
      echo "=========================================="
      echo "Deployment done"
      echo "=========================================="

      echo "pod status"
      kubectl get pods -n todo
      echo ""
      echo "looking for services"
      kubectl get svc -n todo
      
      echo ""
      echo ""
      echo "To check logs:"
      echo "  kubectl logs -n todo -l app=frontend"
      echo "  kubectl logs -n todo -l app=api"
      echo "  kubectl logs -n todo -l app=mongodb"
    EOT
  }
}

# output 
output "minikube_ip" {
  description = "Minikube cluster IP"
  value       = "Run 'minikube ip' to get the IP"
}

