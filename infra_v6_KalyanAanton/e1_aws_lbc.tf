data "aws_iam_policy_document" "aws_lbc" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole", "sts:TagSession"]
  }
}

resource "aws_iam_role" "aws_lbc" {
  name               = "${local.env}-${local.eks_name}-RoleForLBC"
  assume_role_policy = data.aws_iam_policy_document.aws_lbc.json
}

# policy for AWS controller
# this time we use policy from file
resource "aws_iam_policy" "aws_lbc" {
  name   = "${local.env}-${local.eks_name}-AWSLoadBalancerControllerPolicy"
  policy = file("e2-AWSLoadBalancerControllerPolicy.json")
}
resource "aws_iam_role_policy_attachment" "aws_lbc" {
  role       = aws_iam_role.aws_lbc.name
  policy_arn = aws_iam_policy.aws_lbc.arn
}

# we link role with kubernetes service account
resource "aws_eks_pod_identity_association" "aws_lbc" {
  cluster_name    = aws_eks_cluster.eks.name
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"
  role_arn        = aws_iam_role.aws_lbc.arn
}

# we deploy controller using helm chart
resource "helm_release" "aws_lbc" {
  name = "aws-load-balancer-controller"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.7.2"

  set {
    name  = "clusterName"
    value = aws_eks_cluster.eks.name
  }
  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
  set {
    name  = "ingressClassConfig.default"
    value = "true"
  }
  # kubectl get ingressclass -oyaml
  # kubectl describe ingressclass alb |y
  # kubectl -n kube-system  get po | grep -E 'balancer|NAME' |c
  depends_on = [ aws_eks_node_group.eks_ng_private, aws_iam_role.aws_lbc] # [helm_release.cluster_autoscaler]
}

# output "zzzz" {#   value = data.aws_iam_policy_document.aws_lbc}
output "helm_ver_lbc" {
  value = helm_release.aws_lbc.version
  #value       = helm_release.aws_lbc.metadata
}

# https://youtu.be/5XpPiORNy1o?si=dOnzA2WA6fRnoCuK
# https://github.com/aws/eks-charts/blob/master/stable/aws-load-balancer-controller/README.md