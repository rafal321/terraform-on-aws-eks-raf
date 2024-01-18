# Create AWS EKS Node Group - private
resource "aws_eks_node_group" "eks_ng_private" {
  cluster_name = var.eks_cluster_id
  lifecycle { create_before_destroy = true }

  node_group_name = "${var.eks_ng_private_name}-eks-ng-private"
  node_role_arn   = aws_iam_role.eks_nodegroup_role.arn
  subnet_ids      = var.vpc_private_subnets
  # version = "1.28"                      # RAF: use for upgrade only

  ami_type       = var.ami_type # "AL2_x86_64"
  capacity_type  = "SPOT"
  disk_size      = var.disk_size
  instance_types = var.instance_types

  #remote_access {
  #   ec2_ssh_key = "eks-terraform-key"     # 71.step-11
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
    network_type    = "private"
    ami_type        = var.ami_type
    lifecycle       = "spot"
    node_group_name = "${var.eks_ng_private_name}-eks-ng-private"
  }
  tags = { # tags applied to EKS Nodegroup Tags - (NOT EC2s)
    network_type                                      = "private"
    ami_type                                          = var.ami_type
    lifecycle                                         = "spot"
    node_group_name                                   = "${var.eks_ng_private_name}-eks-ng-private"
    rk_testing                                        = "AbC"
    "k8s.io/cluster-autoscaler/enabled"               = "true"
    "k8s.io/cluster-autoscaler/${var.eks_cluster_id}" = "owned"
  }
}
######################################
# Tag Instances in autoscaling group
######################################
resource "aws_autoscaling_group_tag" "this" {
  autoscaling_group_name = aws_eks_node_group.eks_ng_private.resources[0].autoscaling_groups[0].name
  tag {
    key                 = "Name"
    value               = "${var.eks_ng_private_name}-eks-ng-private-worker"
    propagate_at_launch = true
  }
}


#output "zzzz"  {
# value = aws_eks_node_group.eks_ng_private
#  value = aws_eks_node_group.eks_ng_private.resources[0].autoscaling_groups[0].name
#  }
