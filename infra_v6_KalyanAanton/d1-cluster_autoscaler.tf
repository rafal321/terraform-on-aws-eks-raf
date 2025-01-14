# Cluster Autoscaler Tutorial (EKS Pod Identities): AWS EKS Kubernetes Tutorial - Part 5
# https://www.youtube.com/watch?v=HbRyRJnBEfw&t=59s
# https://youtu.be/0EWsKSdmbz0?si=fvVlrxY5gjMqhYF5 

resource "aws_iam_role" "cluster_autoscaler" {
  name = "${aws_eks_cluster.eks.name}-RoleForClusterAutoscaler"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
      }
    ]
  })
}
# For trust relationship we always use: Service = "pods.eks.amazonaws.com"

resource "aws_iam_policy" "cluster_autoscaler" {
  name = "${aws_eks_cluster.eks.name}-ClusterAutoscalerPolicy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeScalingActivities",
          "autoscaling:DescribeTags",
          "ec2:DescribeImages",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:GetInstanceTypesFromInstanceRequirements",
          "eks:DescribeNodegroup"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup"
        ]
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {
  policy_arn = aws_iam_policy.cluster_autoscaler.arn
  role       = aws_iam_role.cluster_autoscaler.name
}

resource "aws_eks_pod_identity_association" "cluster_autoscaler" {
  cluster_name    = aws_eks_cluster.eks.name
  namespace       = "kube-system"
  service_account = "cluster-autoscaler"
  role_arn        = aws_iam_role.cluster_autoscaler.arn
}

# deploy autoscaler to EKS
data "aws_region" "current" {}
resource "helm_release" "cluster_autoscaler" {
  name       = "autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"
  version    = "9.37.0"
  set {
    name  = "rbac.serviceAccount.name"
    value = "cluster-autoscaler"
  }
  set {
    name  = "autoDiscovery.clusterName"
    value = aws_eks_cluster.eks.name
  }
  # MUST be updated to match your region
  set {
    name  = "awsRegion"
    value = data.aws_region.current.name
  }
  depends_on = [helm_release.metrics_server]
}
# output "zzz1" {
#   value = data.aws_region.current
# }

# aws eks describe-addon-versions --profile eksuser --addon-name eks-pod-identity-agent | grep addonVersion