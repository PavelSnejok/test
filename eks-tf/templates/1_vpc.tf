# Create a VPC
resource "aws_vpc" "vpc" {
  cidr_block                = var.vpc_cidr
  instance_tenancy          = "default"        # Default kind (instances within a VPC are launched on shared hardware with other customers)
                                      # Dedicated (instances within a VPC are launched on dedicated hardware that is exclusively used by a single customer)
  enable_dns_support        = true             # Defaults to true.
  enable_dns_hostnames      = true             # Defaults false.

  tags                                           = {
    Name                                         = "vpc-${var.cluster_name}"
    "kubernetes.io/cluster/${var.cluster_name}"  = "owned"
  }
}

# Create an IG
resource "aws_internet_gateway" "igw" {
    vpc_id                  = aws_vpc.vpc.id

  tags                                           = {
    Name                                         = "igw-${var.cluster_name}"
  }
}

# Create a Public Route Table for Public Subnets
resource "aws_route_table" "public_route_table" {
  vpc_id                    = aws_vpc.vpc.id

  route {
      cidr_block            = "0.0.0.0/0"
      gateway_id            = aws_internet_gateway.igw.id
  }

  tags                                           = {
    Name                                         = "Public-Rout-Table-${var.cluster_name}"
  }

  depends_on = [ aws_internet_gateway.igw ]
}

# Create 3 Public Subnets with resources and Depending resources on it
resource "aws_subnet" "public_subnet" {
  vpc_id                    = aws_vpc.vpc.id
  map_public_ip_on_launch   = true          # Requered for EKS. Instance launched into the subnet should be assigned a public IP
  
  
  count                     = 3
  cidr_block                = "${cidrsubnet(var.vpc_cidr, 8, var.puclic_subnet_offset + count.index)}"
  availability_zone         = element(["${var.region}a", "${var.region}b", "${var.region}c"], count.index)
  
  tags                                           = {
    Name                                         = "Public_Subnet_#${var.puclic_subnet_offset + count.index}"
    "kubernetes.io/cluster/${var.cluster_name}"  = "shared"
    "kubernetes.io/role/elb"                     = 1
  }

    depends_on = [ aws_internet_gateway.igw, aws_route_table.public_route_table ]
}

# Associate Public Subnets with a Route Table for Internet access to it
resource "aws_route_table_association" "public_subnet_association" {
    for_each                = {for i, subnet in aws_subnet.public_subnet : i => subnet.id}
    subnet_id               = each.value
    route_table_id          = aws_route_table.public_route_table.id

    depends_on = [ 
      aws_subnet.public_subnet,
      aws_route_table.public_route_table
     ]
}

# Crete a Route Table for Private Subnets
resource "aws_route_table" "private_route_table" {
    vpc_id                  = aws_vpc.vpc.id

  tags                                           = {
    Name                                         = "Private-Rout-Table-${var.cluster_name}"
  }
}

#Create 3 Private Subnets with resources and Depending resources on it
resource "aws_subnet" "private_subnet" {
    vpc_id                   = aws_vpc.vpc.id

    count                    = 3
    cidr_block               = "${cidrsubnet(var.vpc_cidr, 8, var.private_subnet_offset + count.index)}"
    availability_zone        = element(["${var.region}a", "${var.region}b", "${var.region}c"], count.index)
    
  tags                                           = {
    Name                                         = "Private_Subnet_#${var.private_subnet_offset + count.index}"
    "kubernetes.io/cluster/${var.cluster_name}"  = "shared"
    "kubernetes.io/role/internal-elb"            = 1
  }

    depends_on = [ aws_route_table.private_route_table ]
}

# Associate Private Subnets with a Route Table
resource "aws_route_table_association" "private_subnet_association" {
    for_each                = {for i, subnet in aws_subnet.private_subnet : i => subnet.id}
    subnet_id               = each.value
    route_table_id          = aws_route_table.private_route_table.id

    depends_on = [ 
      aws_subnet.private_subnet,
      aws_route_table.private_route_table
     ]
}