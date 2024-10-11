resource "aws_iam_role" "nodes" {
  name               = "${local.env}-${local.eks_name}-RoleForAmazonEKSNodegroup"
  assume_role_policy = <<POLICY
    {
    "Version": "2012-10-17",
    "Statement": [{
        "Effect": "Allow",
        "Principal": {"Service": "ec2.amazonaws.com"},
        "Action": "sts:AssumeRole"
        }]}
POLICY
}
resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes.name
}
resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes.name
  # to manage secondary IPs for pods
}
resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2RoleforSSM" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
  role       = aws_iam_role.nodes.name
}
resource "aws_iam_role_policy_attachment" "AmazonDynamoDBFullAccessM" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
  role       = aws_iam_role.nodes.name
  # Raf: I need this for: 15-ACG-Hands-On_with_Amazon_EKS-2023
}

# ------------------------------------------------------------------------------------------
# --- NODES PRIVATE -------------------------------------------------------------------------
resource "aws_eks_node_group" "eks_ng_private" {
  cluster_name    = aws_eks_cluster.eks.name
  version         = local.eks_ver_ng
  node_group_name = "${local.eks_name}-ng-private"
  node_role_arn   = aws_iam_role.nodes.arn
  subnet_ids      = local.subnets_pri

  ami_type       = "AL2_x86_64" #"BOTTLEROCKET_x86_64"
  capacity_type  = "SPOT"
  disk_size      = 20
  instance_types = ["t3.large", "t2.large", "r5.large", "r6a.large"] # "r6a.large"

  scaling_config {
    desired_size = 2
    min_size     = 2
    max_size     = 9
  }
  # Explained: Cluster Autoscaler Tutorial (EKS Pod Identities): AWS EKS Kubernetes Tutorial - Part 5
  lifecycle { ignore_changes = [scaling_config[0].desired_size] }

  update_config { max_unavailable = 1 }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly
  ]
  timeouts {
    create = "15m"
    update = "25m"
    delete = "15m"
  }
  labels = {
    role            = "general"
    lifecycle       = "spot"
    network_type    = "private"
    node_group_name = "${local.eks_name}-ng-private"
  }
  tags = {
    # "k8s.io/cluster-autoscaler/enabled"               = "true"        # looks like these tags are on by default now
    # "k8s.io/cluster-autoscaler/${var.eks_cluster_id}" = "owned"       # looks like these tags are on by default now
    role            = "general"
    lifecycle       = "spot"
    network_type    = "private"
    node_group_name = "${local.eks_name}-ng-private"
  }
}
######################################
# Tag Instances in autoscaling group
######################################
resource "aws_autoscaling_group_tag" "this_private" {
  autoscaling_group_name = aws_eks_node_group.eks_ng_private.resources[0].autoscaling_groups[0].name
  tag {
    key                 = "Name"
    value               = aws_eks_node_group.eks_ng_private.node_group_name
    propagate_at_launch = true
  }
}
output "ng_pri_version" { value = aws_eks_node_group.eks_ng_private.version }
output "ng_pri_name" { value = aws_eks_node_group.eks_ng_private.node_group_name }
# ------------------------------------------------------------------------------------------
# --- NODES PUBLIC -------------------------------------------------------------------------
# resource "aws_eks_node_group" "eks_ng_public" {
#   cluster_name    = aws_eks_cluster.eks.name
#   version         = local.eks_ver_ng
#   node_group_name = "${local.eks_name}-ng-public"
#   node_role_arn   = aws_iam_role.nodes.arn
#   subnet_ids      = local.subnets_pub

#   ami_type       = "BOTTLEROCKET_x86_64"
#   capacity_type  = "SPOT"
#   disk_size      = 20
#   instance_types = ["t3.large", "t2.large", "r5.large"]

#   scaling_config {
#     desired_size = 2
#     min_size     = 2
#     max_size     = 6
#   }
#   # Explained: Cluster Autoscaler Tutorial (EKS Pod Identities): AWS EKS Kubernetes Tutorial - Part 5
#   lifecycle { ignore_changes = [scaling_config[0].desired_size] }

#   update_config { max_unavailable = 1 }

#   # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
#   # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
#   depends_on = [
#     aws_iam_role_policy_attachment.amazon_eks_worker_node_policy,
#     aws_iam_role_policy_attachment.amazon_eks_cni_policy,
#     aws_iam_role_policy_attachment.amazon_ec2_container_registry_read_only_policy
#   ]
#   labels = {
#     role            = "general"
#     lifecycle       = "spot"
#     network_type    = "public"
#     node_group_name = "${local.eks_name}-ng-public"
#   }
#   tags = {
#     # "k8s.io/cluster-autoscaler/enabled"               = "true"        # looks like these tags are on by default now
#     # "k8s.io/cluster-autoscaler/${var.eks_cluster_id}" = "owned"       # looks like these tags are on by default now
#     role            = "general"
#     lifecycle       = "spot"
#     network_type    = "public"
#     node_group_name = "${local.eks_name}-ng-public"
#   }
# }
# ######################################
# # Tag Instances in autoscaling group
# ######################################
# resource "aws_autoscaling_group_tag" "this_public" {
#   autoscaling_group_name = aws_eks_node_group.eks_ng_public.resources[0].autoscaling_groups[0].name
#   tag {
#     key                 = "Name"
#     value               = aws_eks_node_group.eks_ng_public.node_group_name
#     propagate_at_launch = true
#   }
# }
# output "ng_pub_version" { value = aws_eks_node_group.eks_ng_public.version }
# output "ng_pub_name" { value = aws_eks_node_group.eks_ng_public.node_group_name }

