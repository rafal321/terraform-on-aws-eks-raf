# Resource: aws_eks_node_group
#/*
resource "aws_eks_node_group" "eks_ng_public" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.cluster_name}-eks-ng-public"
  node_role_arn   = aws_iam_role.eks_nodegroup_role.arn
  subnet_ids      = var.vpc_public_subnets
  # version = "1.28"                      # RAF: use for upgrade only

  ami_type       = var.ami_type # "AL2_x86_64"
  capacity_type  = "SPOT"
  disk_size      = var.disk_size
  instance_types = var.instance_types

  scaling_config {
    desired_size = var.desired_size
    min_size     = var.min_size
    max_size     = var.max_size
  }
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
    # Explained: Cluster Autoscaler Tutorial (EKS Pod Identities): AWS EKS Kubernetes Tutorial - Part 5 - managed by autoscaler
  }

  # Desired max percentage of unavailable worker nodes during node group update.
  update_config {
    max_unavailable = 1
    #max_unavailable_percentage = 50    # ANY ONE TO USE
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks-AmazonEC2ContainerRegistryReadOnly
  ]
  labels = {
    lifecycle       = "spot"
    network_type    = "public"
    ami_type        = var.ami_type
    lifecycle       = "spot"
    node_group_name = "${var.cluster_name}-eks-ng-public"
  }
  tags = {
    # "k8s.io/cluster-autoscaler/enabled"               = "true"        # looks like these tags are on by default now
    # "k8s.io/cluster-autoscaler/${var.eks_cluster_id}" = "owned"       # looks like these tags are on by default now
    lifecycle       = "spot" # tags are not applied anyways!!!
    network_type    = "public"
    ami_type        = var.ami_type
    lifecycle       = "spot"
    node_group_name = "${var.cluster_name}-eks-ng-public"
  }
}
######################################
# Tag Instances in autoscaling group
######################################
resource "aws_autoscaling_group_tag" "this_public" {
  autoscaling_group_name = aws_eks_node_group.eks_ng_public.resources[0].autoscaling_groups[0].name
  tag {
    key                 = "Name"
    value               = "${var.cluster_name}-eks-ng-public" # eksdemo-eks-ng-public
    propagate_at_launch = true
  }
}

output "node_group_public_id" { value = aws_eks_node_group.eks_ng_public.id }
output "node_group_public_arn" { value = aws_eks_node_group.eks_ng_public.arn }
output "node_group_public_status" { value = aws_eks_node_group.eks_ng_public.status }
output "node_group_public_version" { value = aws_eks_node_group.eks_ng_public.version }
output "node_group_public_name" { value = aws_eks_node_group.eks_ng_public.node_group_name }
# */
