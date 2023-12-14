# EKS Node Group Outputs - Public
output "eks_ng_public_id" {
  description = "Public Node Group ID"
  value       = aws_eks_node_group.eks_ng_public.id
}

output "eks_ng_public_arn" {
  description = "Public Node Group ARN"
  value       = aws_eks_node_group.eks_ng_public.arn
}

output "eks_ng_public_status" {
  description = "Public Node Group status"
  value       = aws_eks_node_group.eks_ng_public.status
}

output "eks_ng_public_version" {
  description = "Public Node Group Kubernetes Version"
  value       = aws_eks_node_group.eks_ng_public.version
}