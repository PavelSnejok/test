# Create IAM Role for EKS cluster (contains: aws_iam_role, aws_iam_policy_document, aws_iam_role_policy_attachment)
resource "aws_iam_role" "eks_cluster_role" {
  name                      = "eks-cluster-role-${var.cluster_name}"
  assume_role_policy        = data.aws_iam_policy_document.eks_cluster_role_json.json

  tags                                           = {
    Name                                         = "eks-cluster-role-${var.cluster_name}"
  }
}

data "aws_iam_policy_document" "eks_cluster_role_json" {
  statement {
      effect = "Allow"

      principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
      }

      actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_role_policy_attachment" {
  for_each                  = toset(var.eks_policy_attachment)
  policy_arn                = each.value
  role                      = aws_iam_role.eks_cluster_role.name
}

# Create EC2 Role for EKS cluster (contains: aws_iam_role, aws_iam_policy_document, aws_iam_role_policy_attachment)
resource "aws_iam_role" "ec2_cluster_role" {
  name                      = "ec2-cluster-role-${var.cluster_name}"
  assume_role_policy        = data.aws_iam_policy_document.ec2_cluster_role_json.json

  tags                                           = {
    Name                                         = "ec2-cluster-role-${var.cluster_name}"
  }
}

data "aws_iam_policy_document" "ec2_cluster_role_json" {
  statement {
      effect = "Allow"

      principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
      }

      actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "ec2_cluster_role_policy_attachment" {
  for_each                  = toset(var.ec2_policy_attachment)
  policy_arn                = each.value
  role                      = aws_iam_role.ec2_cluster_role.name
}

# Create Jenkins Secret Access Role for pod in EKS cluster (contains: aws_iam_role, aws_iam_policy_document, aws_iam_role_policy_attachment)
resource "aws_iam_role" "jenkins_secret_access" {
  name                      = "jenkins-secret-access-${var.cluster_name}"
  assume_role_policy        = data.aws_iam_policy_document.jenkins_secret_access_json.json

  tags                                           = {
    Name                                         = "jenkins-secret-access-${var.cluster_name}"
  }
}

data "aws_iam_policy_document" "jenkins_secret_access_json" {
  statement {
      effect = "Allow"

      principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
      }

      actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "jenkins_secret_role_policy_attachment" {
  for_each                  = toset(var.jenkins_secret_access)
  policy_arn                = each.value
  role                      = aws_iam_role.jenkins_secret_access.name
}