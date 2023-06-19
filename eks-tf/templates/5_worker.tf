# Create SSH key for Worker Node
resource "tls_private_key" "key_for_eks" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "local_file" "public_key" {
  filename = "ssh/eks-test-key"
  content = tls_private_key.key_for_eks.public_key_openssh
}

resource "local_file" "privare_key" {
  filename = "ssh/eks-test-key.pem"
  content = tls_private_key.key_for_eks.private_key_pem
}

resource "aws_key_pair" "eks_key_worker_node" {
  key_name = "eks-test-key"
  public_key = tls_private_key.key_for_eks.public_key_openssh
}

# Create IAM Instance Profile for Worker Nodes
resource "aws_iam_instance_profile" "eks_ec2_instance_profile" {
  name                      = "ec2-instance-profile-${var.cluster_name}"
  role                      = aws_iam_role.ec2_cluster_role.name
}

# Create Launch template for Worker Node
resource "aws_launch_template" "ec2_worker_launch_template" {
  name_prefix               = "ec2-worker-launch-template-${var.cluster_name}"
  image_id                  = var.image_id_ec2
  instance_type             = var.instance_type_ec2
  key_name                  = "eks-test-key"

  iam_instance_profile {
    arn = aws_iam_instance_profile.eks_ec2_instance_profile.arn
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      delete_on_termination = true
      volume_type = var.ebs_volume_type
      volume_size = var.ebs_volume_size
    }
  }
  
  vpc_security_group_ids = [
    aws_security_group.security_group_ec2_worker_node.id
    ]

  user_data = base64encode(
    <<-EOF
    #!/bin/bash
    /etc/eks/bootstrap.sh ${var.cluster_name} --container-runtime containerd
    EOF
  )

  metadata_options {
      http_endpoint               = "enabled"
      http_tokens                 = "required"
      http_put_response_hop_limit = 2
  }

  tags                                           = {
    Name                                         = "${var.cluster_name}_ec2_instance"
  }
}

resource "aws_autoscaling_group" "ec2_worker_autoscaling" {
  name_prefix = "ec2-worker-auto-scaling-${var.cluster_name}"
  desired_capacity   = var.desired_size_ec2
  max_size           = var.max_size_ec2
  min_size           = var.min_size_ec2
  capacity_rebalance = true
  vpc_zone_identifier = [for subnet in aws_subnet.public_subnet : subnet.id]

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = var.on_demand_base_capacity
      on_demand_percentage_above_base_capacity = var.on_demand_percentage_capacity
      spot_allocation_strategy                 = var.spot_allocation_strategy
    }

    launch_template {
        launch_template_specification {
          launch_template_id = aws_launch_template.ec2_worker_launch_template.id
          version = "$Latest"
        }
    }
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 100
    }
  }

  tag                             {
    key                           = "Name"
    value                         = "${var.cluster_name}"
    propagate_at_launch           = true
  }

    tag                             {
    key                           = "kubernetes.io/cluster/${var.cluster_name}"
    value                         = "owned"
    propagate_at_launch           = true
  }

    tag                             {
    key                           = "k8s.io/cluster-autoscaler/${var.cluster_name}"
    value                         = "owned"
    propagate_at_launch           = true
  }

    tag                             {
    key                           = "k8s.io/cluster-autoscaler/enabled"
    value                         = "true"
    propagate_at_launch           = true
  }
}


###########################

# # Create EC2 Worker Node for EKS cluster
# resource "aws_eks_node_group" "eks_work_node_ec2" {
#     cluster_name    = aws_eks_cluster.eks_cluster.name
#     node_group_name = "${var.cluster_name}_work_node_ec2"
#     node_role_arn   = aws_iam_role.ec2_cluster_role.arn
#     subnet_ids      = [for subnet in aws_subnet.public_subnet : subnet.id]

#     scaling_config {
#         desired_size = var.desired_size_ec2
#         max_size     = var.max_size_ec2
#         min_size     = var.min_size_ec2
#     }

#     launch_template {
 
#     }

  

#     ami_type = var.aim_type_ec2
#     capacity_type = var.capacity_type_ec2
#     disk_size = var.disk_size_ec2
#     force_update_version = false
#     instance_types = var.instance_type_ec2
#     version = var.cluster_version
#     capacity = {

#     }

#   tags                                           = {
#     Name                                         = "${var.cluster_name}_worker_node"
#     "kubernetes.io/cluster/${var.cluster_name}"  = "shared"
#   }

#     update_config {
#         max_unavailable = 1
#     }

#     # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
#     # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
#     depends_on = [
#         aws_iam_role_policy_attachment.ec2_cluster_role_AmazonEKSWorkerNodePolicy,
#         aws_eks_cluster.eks_cluster,
#         aws_security_group.security_group_ec2_worker_node
#     ]
# }