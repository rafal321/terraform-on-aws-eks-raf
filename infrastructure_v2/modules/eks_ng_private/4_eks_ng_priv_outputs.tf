output "eks_ng_private_id" {
  description = "Node Group 1 ID"
  value       = aws_eks_node_group.eks_ng_private.id
}

output "eks_ng_private_arn" {
  description = "Private Node Group ARN"
  value       = aws_eks_node_group.eks_ng_private.arn
}

output "eks_ng_private_status" {
  description = "Private Node Group status"
  value       = aws_eks_node_group.eks_ng_private.status
}

output "eks_ng_private_version" {
  description = "Private Node Group Kubernetes Version"
  value       = aws_eks_node_group.eks_ng_private.version
}

output "eks_ng_private_asg_name" {
  description = "Private Node Group Kubernetes Version"
  value       = aws_eks_node_group.eks_ng_private.resources[0].autoscaling_groups[0].name
}
