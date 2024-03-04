# Create AWS EKS Node Group - public
resource "aws_eks_node_group" "eks_ng_public" {
  cluster_name = var.eks_cluster_id
  lifecycle { create_before_destroy = true }

  node_group_name = "${var.eks_ng_public_name}-eks-ng-public"
  node_role_arn   = aws_iam_role.eks_nodegroup_role.arn
  # subnet_ids      = module.vpc.public_subnets
  subnet_ids = var.vpc_public_subnets
  # version = "1.28"                      # RAF: use for upgrade only

  ami_type       = var.ami_type # "AL2_x86_64"
  capacity_type  = "SPOT"
  disk_size      = var.disk_size
  instance_types = var.instance_types

  #remote_access {
  #   ec2_ssh_key = "eks-terraform-key"
  # }

  scaling_config {
    desired_size = var.desired_size
    min_size     = var.min_size
    max_size     = var.max_size
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
    aws_iam_role_policy_attachment.eks-AmazonEC2ContainerRegistryReadOnly,
  ]
  labels = {
    lifecycle = "spot"
    rk_label  = "rk_label_val01"
    node_group = "public"
    ami_type = var.ami_type
  }
  tags = {
    tagat34hx3a = "value34hx3a"
    node_group = "public"
    ami_type = var.ami_type
  }
}
######################################
# Tag Instances in autoscaling group
######################################
resource "aws_autoscaling_group_tag" "this" {
  autoscaling_group_name = aws_eks_node_group.eks_ng_public.resources[0].autoscaling_groups[0].name
  tag {
    key                 = "Name"
    value               = "${var.eks_ng_public_name}-eks-ng-public-worker"
    propagate_at_launch = true
  }
}

#output "zzzz"  {
# value = aws_eks_node_group.eks_ng_public
#  value = aws_eks_node_group.eks_ng_public.resources[0].autoscaling_groups[0].name
#  }
