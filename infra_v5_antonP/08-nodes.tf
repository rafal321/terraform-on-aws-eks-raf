resource "aws_iam_role" "nodes" {
  name               = "${local.env}-${local.eks_name}-eks-nodes"
  assume_role_policy = <<POLICY
    {
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Principal": {
            "Service": "ec2.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
    ]
    }
POLICY
}
resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes.name
}
resource "aws_iam_role_policy_attachment" "amazon_eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes.name
  # to manage secondary IPs for pods
}
resource "aws_iam_role_policy_attachment" "amazon_ec2_container_registry_read_only_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes.name
}
# --- NODES -------------------------------------------------------------------------
resource "aws_eks_node_group" "eks_ng_private" {
  cluster_name    = aws_eks_cluster.eks.name
  version         = local.eks_version
  node_group_name = "general"
  node_role_arn   = aws_iam_role.nodes.arn
  subnet_ids      = [aws_subnet.private_zone1.id, aws_subnet.private_zone2.id]

  ami_type       = "BOTTLEROCKET_x86_64"
  capacity_type  = "SPOT"
  disk_size      = 25
  instance_types = ["t3.large", "t2.large", "r5.large"]

  scaling_config {
    desired_size = 2
    min_size     = 2
    max_size     = 6
  }
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
    # Explained: Cluster Autoscaler Tutorial (EKS Pod Identities): AWS EKS Kubernetes Tutorial - Part 5
  }

  # Desired max percentage of unavailable worker nodes during node group update.
  update_config {
    max_unavailable = 1
    #max_unavailable_percentage = 50    # ANY ONE TO USE
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.amazon_eks_worker_node_policy,
    aws_iam_role_policy_attachment.amazon_eks_cni_policy,
    aws_iam_role_policy_attachment.amazon_ec2_container_registry_read_only_policy
  ]
  labels = {
    role            = "general"
    lifecycle       = "spot"
    network_type    = "private"
    node_group_name = "general"
  }
  tags = {
    # "k8s.io/cluster-autoscaler/enabled"               = "true"        # looks like these tags are on by default now
    # "k8s.io/cluster-autoscaler/${var.eks_cluster_id}" = "owned"       # looks like these tags are on by default now
    role            = "general"
    lifecycle       = "spot"
    network_type    = "private"
    node_group_name = "general"
  }
}
######################################
# Tag Instances in autoscaling group
######################################
resource "aws_autoscaling_group_tag" "this_private" {
  autoscaling_group_name = aws_eks_node_group.eks_ng_private.resources[0].autoscaling_groups[0].name
  tag {
    key                 = "Name"
    value               = "general-ng-private"
    propagate_at_launch = true
  }
}

output "ng_pri_version" {
  value = aws_eks_node_group.eks_ng_private.version
}
output "ng_pri_name" {
  value = aws_eks_node_group.eks_ng_private.node_group_name
}
output "ng_pri_tag" {
  value = aws_autoscaling_group_tag.this_private.tag[0].value
}
/*
output "node_group_private_id" { value = aws_eks_node_group.eks_ng_private.id }
output "node_group_private_arn" { value = aws_eks_node_group.eks_ng_private.arn }
output "node_group_private_status" { value = aws_eks_node_group.eks_ng_private.status }
output "node_group_private_version" { value = aws_eks_node_group.eks_ng_private.version }
output "node_group_private_name" { value = aws_eks_node_group.eks_ng_private.node_group_name }
*/