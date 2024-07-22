
# Section: 42,43,44 
# 1] create namespace:  fp-ns-app1
#   I did it manually

# Resource: IAM Role for EKS Fargate Profile
resource "aws_iam_role" "fargate_profile_role" {
  name = "${var.cluster_name}-eks-fargate-profile-role-apps"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks-fargate-pods.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

# Resource: IAM Policy Attachment to IAM Role
resource "aws_iam_role_policy_attachment" "eks_fargate_pod_execution_role_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate_profile_role.name
}

# Resource: EKS Fargate Profile
resource "aws_eks_fargate_profile" "fargate_profile" {
  cluster_name           = aws_eks_cluster.eks_cluster.id
  fargate_profile_name   = "${var.cluster_name}-fp-app1"
  pod_execution_role_arn = aws_iam_role.fargate_profile_role.arn
  subnet_ids             = var.vpc_private_subnets
  selector {
    namespace = "fp-ns-app1"
  }
}



