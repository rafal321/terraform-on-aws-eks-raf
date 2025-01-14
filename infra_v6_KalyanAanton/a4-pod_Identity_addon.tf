resource "aws_eks_addon" "pod_identity" {
  cluster_name  = aws_eks_cluster.eks.name
  addon_name    = "eks-pod-identity-agent"
  addon_version = "v1.3.4-eksbuild.1" # "v1.3.2-eksbuild.2"
}
# to get latest version
# aws eks describe-addon-versions --profile lab --addon-name eks-pod-identity-agent
# aws eks describe-addon-versions --profile lab --output text | grep -C 4 eks-pod-identity-agent
# aws eks describe-addon-versions --profile dev --addon-name eks-pod-identity-agent --output table --no-cli-pager | grep eksbuild
# aws eks describe-addon-versions --profile eksuser --addon-name eks-pod-identity-agent | grep addonVersion