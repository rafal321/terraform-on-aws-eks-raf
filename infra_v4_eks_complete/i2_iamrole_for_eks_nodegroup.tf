resource "aws_iam_role" "eks_nodegroup_role" {
  name = "${var.cluster_name}-eks-nodegroup-role"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
  tags = {
    tag2491x5a = "value2491x5a"
  }
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodegroup_role.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodegroup_role.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodegroup_role.name
}
# Needed for: Section 54. AWS EKS Monitoring and Logging with kubectl
#               CloudWatch Container Insights
# resource "aws_iam_role_policy_attachment" "eks-CloudWatchAgentServerPolicy" {
#   policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
#   role       = aws_iam_role.eks_nodegroup_role.name
# }
# Rk testing added =========================================================================
resource "aws_iam_role_policy_attachment" "eks-AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.eks_nodegroup_role.name
}
# resource "aws_iam_role_policy_attachment" "eks-AutoScalingFullAccess" {
#   policy_arn = "arn:aws:iam::aws:policy/AutoScalingFullAccess"
#   role       = aws_iam_role.eks_nodegroup_role.name
# }

resource "aws_iam_role_policy_attachment" "eks-AmazonS3FullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.eks_nodegroup_role.name
}

# output "nodegroup_role_arn" { value = aws_iam_role.eks_nodegroup_role.arn }