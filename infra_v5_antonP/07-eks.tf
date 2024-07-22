# https://docs.aws.amazon.com/eks/latest/userguide/private-clusters.html
# https://aws.amazon.com/blogs/containers/de-mystifying-cluster-networking-for-amazon-eks-worker-nodes/
# https://docs.aws.amazon.com/eks/latest/userguide/service_IAM_role.html
resource "aws_iam_role" "eks" {
  name               = "${local.env}-${local.eks_name}-eks-cluster"
  assume_role_policy = <<POLICY
    {
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Principal": {
            "Service": "eks.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
    ]
    }
POLICY
}
resource "aws_iam_role_policy_attachment" "eks" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks.name
}


resource "aws_eks_cluster" "eks" {
  name     = "${local.env}-${local.eks_name}"
  version  = local.eks_version
  role_arn = aws_iam_role.eks.arn
  vpc_config {
    endpoint_private_access = false
    endpoint_public_access  = true
    subnet_ids              = [aws_subnet.private_zone1.id, aws_subnet.private_zone2.id]
  }
  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = "true"
  }
  depends_on = [aws_iam_role_policy_attachment.eks]
}

output "cl_update_kubeconfig" {
  value = "aws eks update-kubeconfig --name ${local.env}-${local.eks_name} --profile ${local.profile}"
}
output "cl_version" {
  value = aws_eks_cluster.eks.version
}
output "cl_id" {
  value = aws_eks_cluster.eks.id
}