###
    # For maint.tf file
# AWS provider
variable region {
  type  =  string
}

###
    # For vpc.tf file
# Custom VPC cidr
variable vpc_cidr {
  type  =  string
}

# Custom Public Subnet offset
variable puclic_subnet_offset {
  type  =  string
}

# Custom Private Subnet offset
variable private_subnet_offset {
  type  =  string
}


###
    # For iam.tf file
# Policy attachment for EKS Cluster Role
variable eks_policy_attachment {
  type = list(string)
  default = [  
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy",

    # "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController",
    # "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    # "arn:aws:iam::aws:policy/AmazonRoute53FullAccess",
    # "arn:aws:iam::aws:policy/AmazonVPCFullAccess" 
    ]
}

# Policy attachment for EKS Cluster Role
variable ec2_policy_attachment {
  type = list(string)
  default = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",

    "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
  ]
}

# Policy attachment for Jenkins Secret Access Role for EKS Cluster role
variable jenkins_secret_access {
  type = list(string)
  default = [
    "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
  ]
}


###
    # For eks.tf file
# EKS Cluster name
variable cluster_name {
  type  =  string
}

# Cluster version
variable cluster_version {
  type  =  string
}


# EC2 instance Desired size
variable desired_size_ec2 {
  type  =  number
}

# EC2 instance Max size
variable max_size_ec2 {
  type  =  number
}

# EC2 instance Min size
variable min_size_ec2 {
  type  =  number
}

# EC2 instance image
variable image_id_ec2 {
  type  =  string
}

# EC2 instance type
variable instance_type_ec2 {
  type  =  string
}



# EBS volume type
variable ebs_volume_type {
  type  =  string
}

# EBS volume size
variable ebs_volume_size {
  type  =  number
}

# EC2 quantity on-demand 
variable on_demand_base_capacity {
  type  =  number
}

# EC2 percentage on-demand
variable on_demand_percentage_capacity {
  type  =  number
}

# EC2 spot allocation strategy
variable spot_allocation_strategy {
  type  =  string
}

# EC2 key pair name
variable "eks_key_worker_node" {
  type  =  string
}

  #   This policy can be useful for creating infrastructure:
  # - AmazonEKSVPCResourceController: The policy grants permissions to the VPC resources required by the EKS cluster, such as creating and managing security groups and network interfaces.

  # - AmazonEC2FullAccess: This policy provides full access to Amazon EC2 resources, allowing the EKS cluster to manage EC2 instances as worker nodes.

  # - AmazonRoute53FullAccess: The policy enables full access to Amazon Route 53, which is needed for managing DNS records and services associated with the EKS cluster.

  # - AmazonVPCFullAccess: This policy grants full access to Amazon VPC resources, enabling management of networking components such as subnets and route tables.

  #     This policy can be useful for creating infrastructure:
  # - service-role/AmazonEBSCSIDriverPolicy: This policy grants permissions for the EBS CSI (Container Storage Interface) driver to manage Amazon EBS volumes used by containers.

  # - AmazonEC2ContainerRegistryFullAccess: The policy provides full access to the Amazon ECR service, allowing push and pull operations for container images within the ECR repositories.