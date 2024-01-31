# Resource: Helm Release
resource "helm_release" "cluster_autoscaler_release" {
  depends_on = [aws_iam_role.cluster_autoscaler_iam_role]
  name       = "${aws_eks_cluster.eks_cluster.name}-ca" # "clas" # "${local.name}-ca"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"
  set {
    name  = "cloudProvider" # default anyways
    value = "aws"
  }
  set {
    name  = "awsRegion" # this was the problem    REQUIRED !!!
    value = "eu-west-1" # awsRegion -- AWS region (required if `cloudProvider=aws`)
  }
  set {
    name  = "autoDiscovery.clusterName"
    value = aws_eks_cluster.eks_cluster.name
  }
  set {
    name  = "rbac.serviceAccount.create" # default anyways
    value = "true"
  }
  set {
    name  = "rbac.serviceAccount.name" # same as in cluster_autoscaler_iam_role
    value = "cluster-autoscaler"
  }
  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.cluster_autoscaler_iam_role.arn
  }
  # Additional Arguments (Optional) - To Test How to pass Extra Args for Cluster Autoscaler
  set {
    name  = "extraArgs.scan-interval"
    value = "15s" # default is 10s
  }
  set {
    name  = "extraArgs.balance-similar-node-groups"
    value = "false"
  }
  set {
    name  = "extraArgs.skip-nodes-with-system-pods" # Raf: I added it
    value = "false"
  }
}
#__________________________________________________
# kubectl -n kube-system get deployment raf-eks-cl-ca-aws-cluster-autoscaler -oyaml | y
# kubectl -n kube-system get cm cluster-autoscaler-status -oyaml |y
# __________________________________________________
# check for more options - extraArgs:       (scale-down-delay-after-add, scan-interval, etc.)
# https://github.com/kubernetes/autoscaler/blob/master/charts/cluster-autoscaler/values.yaml
/*
# Helm Release Outputs
output "cluster_autoscaler_helm_metadata" {
  description = "Metadata Block outlining status of the deployed release."
  value = helm_release.cluster_autoscaler_release.metadata
}
*/