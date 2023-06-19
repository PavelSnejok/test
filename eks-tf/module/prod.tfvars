    # For main.tf file
# Provider AWS
region = "us-east-2"

###
    # For vpc.tf file
# Custom VPC for example "10.0.0.0/8"
vpc_cidr = "172.20.0.0/16"

# Custom Public Subnet offset for example "10.0.--.0/24"
puclic_subnet_offset = "21"

# Custom Private Subnet offset for example "10.0.--.0/24"
private_subnet_offset = "31"


    # For eks.tf file
# EKS cluster name
cluster_name = "prod_eks_dev"

# Cluster version
cluster_version = "1.23"


# EC2 instance Desired size for worker nodes
desired_size_ec2 = 4

# EC2 instance Max size for worker nodes
max_size_ec2 = 10

# EC2 instance Min size for worker nodes
min_size_ec2 = 4

# EC2 AIM Type for worker nodes
image_id_ec2 = "ami-006896008e984456c"

# EC2 AIM Size for worker nodes
instance_type_ec2 = "t3.medium"


# EC2 AIM Type for worker nodes
ebs_volume_type = "gp3"

# EC2 AIM Type for worker nodes
ebs_volume_size = 100


# EC2 quantity on-demand 
on_demand_base_capacity = 4

# EC2 percentage on-demand
on_demand_percentage_capacity = 25

# EC2 key pair name
eks_key_worker_node = "eksnodekey"

# EC2 spot allocation strategy
spot_allocation_strategy = "capacity-optimized"