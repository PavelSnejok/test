provider "aws" {
    region = var.region
}

module "sample_eks_cluster" {
  source                          = "../templates"

  # EKS-cluster variables
  cluster_name                    = var.cluster_name
  cluster_version                 = var.cluster_version

  #EC2-instance variables
  desired_size_ec2                = var.desired_size_ec2
  max_size_ec2                    = var.max_size_ec2
  min_size_ec2                    = var.min_size_ec2
  image_id_ec2                    = var.image_id_ec2
  instance_type_ec2               = var.instance_type_ec2

  ebs_volume_type                 = var.ebs_volume_type
  ebs_volume_size                 = var.ebs_volume_size
  eks_key_worker_node             = var.eks_key_worker_node

  on_demand_base_capacity         = var.on_demand_base_capacity
  on_demand_percentage_capacity   = var.on_demand_percentage_capacity
  spot_allocation_strategy        = var.spot_allocation_strategy

  # VPC variables
  region                          = var.region
  vpc_cidr                        = var.vpc_cidr
  puclic_subnet_offset            = var.puclic_subnet_offset
  private_subnet_offset           = var.private_subnet_offset

  # IAM variables
  eks_policy_attachment           = var.eks_policy_attachment
  ec2_policy_attachment           = var.ec2_policy_attachment
  jenkins_secret_access           = var.jenkins_secret_access
}