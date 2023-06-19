# Create EKS cluster
resource "aws_eks_cluster" "eks_cluster" {
  name                      = var.cluster_name
  version                   = var.cluster_version
  role_arn                  = aws_iam_role.eks_cluster_role.arn

  vpc_config {
      subnet_ids                = [for subnet in aws_subnet.public_subnet : subnet.id]
      security_group_ids        = [aws_security_group.security_group_eks_cluster.id]

      # Indicates whether or not the Amazone EKS private API server endpoint is enabled.
      endpoint_private_access   = true
      endpoint_public_access    = true
  }
 
  tags                                           = {
    Name                                         = var.cluster_name
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_role_policy_attachment,
    aws_subnet.public_subnet,
    aws_security_group.security_group_eks_cluster
  ]
}

# Create EKS resource coredns
# CoreDNS is a DNS server that provides name resolution for services and pods within the cluster.
resource "aws_eks_addon" "eks_coredns" {
  cluster_name                = aws_eks_cluster.eks_cluster.name
  addon_name                  = "coredns"
  addon_version               = "v1.8.7-eksbuild.2"
  resolve_conflicts_on_create = "OVERWRITE"

  depends_on = [
    aws_eks_cluster.eks_cluster
    ]
}

# Create EKS resource vpc-cni
# The vpc-cni add-on is a container networking interface plugin that provides networking functionality for pods within the cluster, allowing them to communicate with each other and with resources outside the cluster.
resource "aws_eks_addon" "eks_vpc_cni" {
  cluster_name                = aws_eks_cluster.eks_cluster.name
  addon_name                  = "vpc-cni"
  addon_version               = "v1.10.4-eksbuild.1"

  depends_on = [
    aws_eks_cluster.eks_cluster
    ]
}

# Create EKS resource kube-proxy
# The kube-proxy is a component of Kubernetes responsible for handling network proxying and load balancing for services within the cluster.
resource "aws_eks_addon" "eks_kube_proxy" {
  cluster_name                = aws_eks_cluster.eks_cluster.name
  addon_name                  = "kube-proxy"
  addon_version               = "v1.23.7-eksbuild.1"

  depends_on = [
    aws_eks_cluster.eks_cluster
    ]
}

# Create EKS resource aws-ebs-csi-driver
# The aws-ebs-csi-driver is a Container Storage Interface (CSI) driver that allows Kubernetes pods to use Amazon Elastic Block Store (EBS) volumes for persistent storage.
resource "aws_eks_addon" "eks_ebs_csi_driver" {
  cluster_name                = aws_eks_cluster.eks_cluster.name
  addon_name                  = "aws-ebs-csi-driver"
  addon_version               = "v1.19.0-eksbuild.1"

  depends_on = [
    aws_eks_cluster.eks_cluster
  ]
}

####### Kubernetes 

# Data using for Kubernetes provider
data "aws_eks_cluster" "data_eks_cluster" {
  name = var.cluster_name

  depends_on = [ aws_eks_cluster.eks_cluster ]
}

# Data using for Kubernetes provider (for data.tf )
data "aws_eks_cluster_auth" "data_eks_cluster_auth" {
  name = var.cluster_name

  depends_on = [ aws_eks_cluster.eks_cluster ]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.data_eks_cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.data_eks_cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.data_eks_cluster_auth.token
}


  ### Data that will be used to create Configmap
# Create Configmap for aws_auth (for eks.tf)
data "aws_iam_role" "ec2_cluster_role" {
  name = "ec2-cluster-role-${var.cluster_name}"
  
  depends_on = [ aws_iam_role.ec2_cluster_role ]
}

# Create Configmap for aws_auth
resource "kubernetes_config_map" "config_map_aws_auth" {
  metadata {
    name = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = <<-EOF
      - groups:
        - system:bootstrappers
        - system:nodes
        - system:masters
        rolearn: ${data.aws_iam_role.ec2_cluster_role.arn}
        username: system:node:{{EC2PrivateDNSName}}
    EOF
  }

  depends_on = [
    aws_eks_cluster.eks_cluster
  ]
}

