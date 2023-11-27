# Create AWS EKS Node Group - Public
resource "aws_eks_node_group" "eks_ng_public" {
  cluster_name = aws_eks_cluster.eks_cluster.name

  node_group_name = "${var.customer}-${var.environment}-eks-ng-public"
  node_role_arn   = aws_iam_role.eks_nodegroup_role.arn
  # subnet_ids      = module.vpc.public_subnets
  subnet_ids = data.terraform_remote_state.vpc_terraform_state.outputs.vpc_public_subnets
  #version = var.cluster_version #(Optional: Defaults to EKS Cluster Kubernetes version)

  ami_type       = "AL2_x86_64"
  capacity_type  = "SPOT"
  disk_size      = 20
  instance_types = ["t3.medium", "t2.medium", "t3a.medium"]

  /*  remote_access {
    ec2_ssh_key = "eks-terraform-key"
  } */

  scaling_config {
    desired_size = 2
    min_size     = 2
    max_size     = 8
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
    lifecycle = "Spot"
    rk_label  = "rk_label_val01"
  }
}
######################################
# Tag Instances in autoscaling group
######################################
resource "aws_autoscaling_group_tag" "this" {
  autoscaling_group_name = aws_eks_node_group.eks_ng_public.resources[0].autoscaling_groups[0].name
  tag {
    key                 = "Name"
    value               = "${var.customer}-${var.environment}-eks-ng-public-worker"
    propagate_at_launch = true
  }
  # depends_on = [ aws_eks_node_group.eks_ng_public ]   RAF: this does not do anything
}

#output "zzzz"  {
# value = aws_eks_node_group.eks_ng_public
#  value = aws_eks_node_group.eks_ng_public.resources[0].autoscaling_groups[0].name
#  }
#
#==========================
/*
 RAF another example
 resource "aws_autoscaling_group_tag" "labels" {
  for_each = local.node_pools

  autoscaling_group_name = aws_eks_node_group.workers[each.key].resources[0].autoscaling_groups[0].name

  dynamic "tag" {
    for_each = each.value.labels

    content {
      key                 = "k8s.io/cluster-autoscaler/node-template/label/${tag.key}"
      value               = tag.value
      propagate_at_launch = false
    }
  }
}
 * */

