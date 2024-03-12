# Create AWS EKS Cluster
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster

resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_master_role.arn
  version  = var.cluster_version

  # where eks ENIs are created
  vpc_config {
    subnet_ids              = var.vpc_public_subnets
    endpoint_private_access = var.cluster_endpoint_private_access      # Default False
    endpoint_public_access  = var.cluster_endpoint_public_access       # Default true
    public_access_cidrs     = var.cluster_endpoint_public_access_cidrs # ["10.30.0.0/16", "109.255.232.193/32"] who can access it on public internet
  }
  # access_config {
  #   authentication_mode = "CONFIG_MAP" # "API_AND_CONFIG_MAP"   "API"
  # }

  kubernetes_network_config {
    service_ipv4_cidr = var.cluster_service_ipv4_cidr
  }

  # Enable EKS Cluster Control Plane Logging - so we can see logs in cloudwatch
  # enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKSVPCResourceController
  ]
  tags = {
    tag101  = "value101"
    Section = "63.Step-03"
  }
}

output "cluster_endpoint" { value = aws_eks_cluster.eks_cluster.endpoint }
output "cluster_certificate_authority_data" { value = aws_eks_cluster.eks_cluster.certificate_authority[0].data }
output "cluster_id" { value = aws_eks_cluster.eks_cluster.id }
output "cluster_arn" { value = aws_eks_cluster.eks_cluster.arn }
output "cluster_version" { value = aws_eks_cluster.eks_cluster.version }
output "cluster_oidc_issuer_url" { value = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer }
output "cluster_update_kubeconfig" { value = "aws eks update-kubeconfig --name ${aws_eks_cluster.eks_cluster.id}" }

