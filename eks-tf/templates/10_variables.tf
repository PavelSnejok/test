###
    # For vpc.tf file
# Custom VPC region
variable region {
  type  =  string
}

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
}

# Policy attachment for EC2 Cluster Role
variable ec2_policy_attachment {
  type = list(string)
}

# Policy attachment for Jenkins Secret Access Role for EKS Cluster role
variable jenkins_secret_access {
  type = list(string)
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