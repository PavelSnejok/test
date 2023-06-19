# Data using for Kubernetes Helm provider
data "aws_eks_cluster" "data_eks_cluster_helm" {
  name = var.cluster_name

  depends_on = [ aws_eks_cluster.eks_cluster ]
}

data "aws_eks_cluster" "data_eks_cluster_helm_ca" {
  name = var.cluster_name

  depends_on = [ aws_eks_cluster.eks_cluster ]
}

data "aws_eks_cluster_auth" "data_eks_cluster_auth_helm" {
  name = var.cluster_name

  depends_on = [ aws_eks_cluster.eks_cluster ]
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.data_eks_cluster_helm.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.data_eks_cluster_helm_ca.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.data_eks_cluster_auth_helm.token
  }
}

resource "kubernetes_namespace" "ingress-nginx_namespace" {
  metadata {
    name = "ingress-nginx"

  }
}

resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  chart      = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  namespace  = "ingress-nginx"

  set {
    name  = "controller.replicaCount"
    value = "1"
  }

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }
  
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "nlb"
  }

  set {
    name  = "controller.admissionWebhooks.patch.enabled"
    value = "true"
  }

    set {
    name  = "controller.admissionWebhooks.patch.admission\\.patch\\.yaml"
    value = "ingress-nginx-admission-patch.yaml"
  }

  depends_on = [
    aws_eks_cluster.eks_cluster,
    aws_autoscaling_group.ec2_worker_autoscaling,
    aws_eks_addon.eks_ebs_csi_driver,
    kubernetes_namespace.ingress-nginx_namespace
  ]
}

# resource "null_resource" "apply_ingress_nginx" {
#   provisioner "local-exec" {
#     command = "sleep 180 && kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.0/deploy/static/provider/aws/deploy.yaml"
#   }
  
#   depends_on = [
#     aws_eks_cluster.eks_cluster,
#     aws_autoscaling_group.ec2_worker_autoscaling
#   ]
# }

