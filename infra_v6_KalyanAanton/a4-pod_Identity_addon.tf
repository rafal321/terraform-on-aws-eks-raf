resource "aws_eks_addon" "pod_identity" {
  cluster_name  = aws_eks_cluster.eks.name
  addon_name    = "eks-pod-identity-agent"
  addon_version = "v1.3.2-eksbuild.2"
}
# to get latest version
# aws eks describe-addon-versions --profile lab --addon-name eks-pod-identity-agent
# aws eks describe-addon-versions --profile lab --output text | grep -C 4 eks-pod-identity-agent