
#=======================================================================
# Create AWS EKS Cluster
resource "aws_eks_cluster" "eks_cluster" {
  name     = var.eks_name
  role_arn = aws_iam_role.eks_master_role.arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids              = var.vpc_public_subnets                   # where eks ENIs are created
    endpoint_private_access = var.cluster_endpoint_private_access      # Default False
    endpoint_public_access  = var.cluster_endpoint_public_access       # Default true
    public_access_cidrs     = var.cluster_endpoint_public_access_cidrs # ["10.30.0.0/16", "109.255.232.193/32"] who can access it on public internet
  }

  kubernetes_network_config {
    service_ipv4_cidr = var.cluster_service_ipv4_cidr
  }

  # Enable EKS Cluster Control Plane Logging - so we can see logs in cloudwatch
  # enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKSVPCResourceController,
  ]
  tags = {
    tag101  = "value101"
    Section = "63.Step-03"
  }
}

#___________________________________________________
# 63. Step-03: Create EKS Cluster Terraform Resource