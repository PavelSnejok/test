  ## EKS Master Cluster Security Group
#Create Security Group for EKS cluster
resource "aws_security_group" "security_group_eks_cluster" {
  name                      = "eks-cluster-sg-${var.cluster_name}"
  description               = "Cluster communication with worker nodes"
  vpc_id                    = aws_vpc.vpc.id

  egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
  }

  tags                                           = {
    Name                                         = "eks-cluster-sg-${var.cluster_name}"
  }
}

# OPTIONAL: Allow inbound traffic from your local workstation external IP
#           to the Kubernetes. You will need to replace A.B.C.D below with
#           your real IP. Services like icanhazip.com can help you find this.
resource "aws_security_group_rule" "cluster-ingress-workstation-https" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.security_group_eks_cluster.id}"
  to_port           = 443
  type              = "ingress"

  depends_on = [ 
    aws_security_group.security_group_eks_cluster
   ]
}

# Worker Node Access to EKS Master Cluster
resource "aws_security_group_rule" "demo-cluster-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.security_group_eks_cluster.id}"
  source_security_group_id = "${aws_security_group.security_group_ec2_worker_node.id}"
  to_port                  = 443
  type                     = "ingress"

  depends_on = [ 
    aws_security_group.security_group_eks_cluster,
    aws_security_group.security_group_ec2_worker_node
   ]
}


  ## Worker Node Security Group
#Create Security Group for EC2 Worker Nodes
resource "aws_security_group" "security_group_ec2_worker_node" {
  name                      = "ec2-worker-node-sg-${var.cluster_name}"
  description               = "Security group for all nodes in the cluster"
  vpc_id                    = aws_vpc.vpc.id

  egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
  }

  tags                                           = {
    Name                                         = "ec2-worker-node-sg-${var.cluster_name}"
    "kubernetes.io/cluster/${var.cluster_name}"  = "owned"
  }
}

resource "aws_security_group_rule" "node-ingress-self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.security_group_ec2_worker_node.id}"
  source_security_group_id = "${aws_security_group.security_group_ec2_worker_node.id}"
  to_port                  = 65535
  type                     = "ingress"

  depends_on = [
    aws_security_group.security_group_ec2_worker_node
   ]
}

resource "aws_security_group_rule" "node-ingress-cluster-https" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.security_group_ec2_worker_node.id}"
  source_security_group_id = "${aws_security_group.security_group_eks_cluster.id}"
  to_port                  = 443
  type                     = "ingress"

  depends_on = [ 
    aws_security_group.security_group_eks_cluster,
    aws_security_group.security_group_ec2_worker_node
   ]
}

resource "aws_security_group_rule" "node-ingress-cluster-others" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.security_group_ec2_worker_node.id}"
  source_security_group_id = "${aws_security_group.security_group_eks_cluster.id}"
  to_port                  = 65535
  type                     = "ingress"

  depends_on = [ 
    aws_security_group.security_group_eks_cluster,
    aws_security_group.security_group_ec2_worker_node
   ]  
}


  ## RDS Security Group
#Create Security Group for EC2 Worker Nodes
resource "aws_security_group" "security_group_rds" {
  name                      = "rds-${var.cluster_name}"
  description               = "Security group for RDS to be availiable from Worker Node"
  vpc_id                    = aws_vpc.vpc.id

  egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
  }

  tags                                           = {
    Name                                         = "rds-${var.cluster_name}"
  }
}

resource "aws_security_group_rule" "rds-ingress-worker-nodes" {
  description              = "Allow RDS be availiable from Worker Nodes"
  from_port                = 3306
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.security_group_rds.id}"
  source_security_group_id = "${aws_security_group.security_group_ec2_worker_node.id}"
  to_port                  = 3306
  type                     = "ingress"

  depends_on = [ 
    aws_security_group.security_group_rds,
    aws_security_group.security_group_ec2_worker_node
   ]  
}