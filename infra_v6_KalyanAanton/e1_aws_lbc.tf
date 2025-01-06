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
  depends_on         = [aws_eks_node_group.eks_ng_private]
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
  depends_on      = [aws_iam_role.aws_lbc]
}

# we deploy controller using helm chart
resource "helm_release" "aws_lbc" {
  name = "aws-load-balancer-controller"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.9.2" # "1.7.2"

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
  depends_on = [aws_iam_role.aws_lbc] # [helm_release.cluster_autoscaler]
}

# output "zzzz" {#   value = data.aws_iam_policy_document.aws_lbc}
output "helm_ver_lbc" {
  value = helm_release.aws_lbc.version
  #value       = helm_release.aws_lbc.metadata
}

# https://youtu.be/5XpPiORNy1o?si=dOnzA2WA6fRnoCuK
# https://github.com/aws/eks-charts/blob/master/stable/aws-load-balancer-controller/README.md

# helm search repo eks
# NAME                                            CHART VERSION   APP VERSION                             DESCRIPTION
# eks/amazon-ec2-metadata-mock                    1.11.2                                                  A Helm chart for Amazon EC2 Metadata Mock
# eks/appmesh-controller                          1.13.1          1.13.1                                  App Mesh controller Helm chart for Kubernetes
# eks/appmesh-gateway                             0.1.5           1.0.0                                   App Mesh Gateway Helm chart for Kubernetes
# eks/appmesh-grafana                             1.0.4           6.4.3                                   App Mesh Grafana Helm chart for Kubernetes
# eks/appmesh-inject                              0.14.8          0.5.0                                   App Mesh Inject Helm chart for Kubernetes
# eks/appmesh-jaeger                              1.0.3           1.29.0                                  App Mesh Jaeger Helm chart for Kubernetes
# eks/appmesh-prometheus                          1.0.3           2.13.1                                  App Mesh Prometheus Helm chart for Kubernetes
# eks/appmesh-spire-agent                         1.0.7           1.5.0                                   SPIRE Agent Helm chart for AppMesh mTLS support...
# eks/appmesh-spire-server                        1.0.7           1.5.0                                   SPIRE Server Helm chart for AppMesh mTLS suppor...
# eks/aws-calico                                  0.3.11          3.19.1                                  A Helm chart for installing Calico on AWS
# eks/aws-cloudwatch-metrics                      0.0.11          1.300032.2b361                          A Helm chart to deploy aws-cloudwatch-metrics p...
# eks/aws-efa-k8s-device-plugin                   v0.5.5          v0.5.4                                  A Helm chart for EFA device plugin.
# eks/aws-for-fluent-bit                          0.1.34          2.32.2.20240516                         A Helm chart to deploy aws-for-fluent-bit project
# eks/aws-load-balancer-controller                1.9.2           v2.9.2                                  AWS Load Balancer Controller Helm chart for Kub...
# eks/aws-node-termination-handler                0.21.0          1.19.0                                  A Helm chart for the AWS Node Termination Handler.
# eks/aws-node-termination-handler-2              0.2.0           2.0.0-beta                              A Helm chart for aws-node-termination-handler, ...
# eks/aws-sigv4-proxy-admission-controller        0.1.2           1                                       AWS SIGv4 Admission Controller Helm Chart for K...
# eks/aws-vpc-cni                                 1.18.5          v1.18.5                                 A Helm chart for the AWS VPC CNI
# eks/cni-metrics-helper                          1.18.5          v1.18.5                                 A Helm chart for the AWS VPC CNI Metrics Helper
# eks/csi-secrets-store-provider-aws              0.0.4           1.0.r2-6-gee95299-2022.04.14.21.07      This Helm chart is deprecated, please switch to...