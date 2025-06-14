# https://docs.aws.amazon.com/eks/latest/userguide/private-clusters.html
# https://aws.amazon.com/blogs/containers/de-mystifying-cluster-networking-for-amazon-eks-worker-nodes/
# https://docs.aws.amazon.com/eks/latest/userguide/service_IAM_role.html
resource "aws_iam_role" "eks" {
  name               = "${local.env}-${local.eks_name}-RoleForAmazonEKS"
  assume_role_policy = <<POLICY
    {"Version": "2012-10-17",
    "Statement": [{
        "Effect": "Allow",
        "Principal": {"Service": "eks.amazonaws.com"},
        "Action": "sts:AssumeRole"
        }]}
POLICY
}

resource "aws_iam_role_policy_attachment" "EKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks.name
}

# Optionally, enable Security Groups for Pods
# https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "EKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks.name
}

# --- CLUSTER -------------------------------------------------------------------------

resource "aws_eks_cluster" "eks" {
  name     = "${local.env}-${local.eks_name}"
  version  = local.eks_ver
  role_arn = aws_iam_role.eks.arn
  vpc_config {
    endpoint_private_access = false
    endpoint_public_access  = true
    subnet_ids              = local.subnets_pub
    public_access_cidrs     = ["0.0.0.0/0"]
  }
  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = "true"
  }
  #kubernetes_network_config {
  #  service_ipv4_cidr = ["172.20.0.0/16"]  is default
  #}

  # Enable EKS Cluster Control Plane Logging - so we can see logs in cloudwatch
  # enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  depends_on = [
    aws_iam_role_policy_attachment.EKSClusterPolicy,
    aws_iam_role_policy_attachment.EKSVPCResourceController
  ]
}
output "cl_update_kubeconfig" { value = "aws eks update-kubeconfig --name ${local.env}-${local.eks_name} --profile ${local.profile}" }
output "cl_version" { value = aws_eks_cluster.eks.version }
output "cl_id" { value = aws_eks_cluster.eks.id }



