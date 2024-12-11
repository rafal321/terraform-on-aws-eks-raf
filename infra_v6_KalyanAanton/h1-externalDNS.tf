resource "aws_iam_policy" "external_dna_policy" {
  name        = "${local.env}-${local.eks_name}-Allow-ExternalDNSUpdates"
  path        = "/"
  description = "External DNS IAM Policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "route53:ChangeResourceRecordSets"
        ],
        "Resource" : [
          "arn:aws:route53:::hostedzone/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets",
          "route53:ListTagsForResource"
        ],
        "Resource" : [
          "*"
        ]
      }
    ]
  })
}
# output "externaldns_iam_policy_arn" {
#   value = aws_iam_policy.externaldns_iam_policy.arn 
# } 

data "aws_iam_policy_document" "externaldns_iam_trust_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:external-dns-sa"]
    }
    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
}

# 2) create IAM role and attach this trust policy
resource "aws_iam_role" "externaldns_iam_role" {
  name               = "${local.env}-${local.eks_name}-externaldns-iam-role"
  assume_role_policy = data.aws_iam_policy_document.externaldns_iam_trust_policy.json
}

# 3) aws has managed policy so we use that
resource "aws_iam_role_policy_attachment" "externaldns_policy_attachement" {
  role       = aws_iam_role.externaldns_iam_role.name
  policy_arn = aws_iam_policy.external_dna_policy.arn
}
# -----------------------------------------------------------------------------------------
# Install external DNS on EKS with helm     -----------------------------------------------

# https://github.com/stacksimplify/terraform-on-aws-eks/tree/main/30-EKS-ExternalDNS-Install
# https://github.com/kubernetes-sigs/external-dns/tree/master/charts/external-dns


resource "helm_release" "external_dns" {
  depends_on = [aws_eks_node_group.eks_ng_private, aws_iam_role.externaldns_iam_role]
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  # version    = "1.15.0" if empty then it's latest   CHART version
  namespace = "kube-system"
  set {
    name  = "serviceAccount.create" # it is default anyway, just for reference
    value = true
  }
  set {
    name  = "serviceAccount.name"
    value = "external-dns-sa"
  }
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.externaldns_iam_role.arn
  }
  set {
    name  = "provider"
    value = "aws"
  }
  set {
    name  = "policy"
    value = "sync"
    # "sync" will ensure that when ingress resource is deleted, equivalent DNS record in Route53 will get deleted
    # Default is "upsert-only" which means DNS records will not get deleted even equivalent Ingress resources are deleted 
    #                      (https://github.com/kubernetes-sigs/external-dns/tree/master/charts/external-dns)
  }
  timeout = 600
  # RAF to fix this - see if it helps:
  # Error: 1 error occurred:
  #│       * Internal error occurred: failed calling webhook "mservice.elbv2.k8s.aws": failed to call webhook: Post "https://aws-load-balancer-webhook-service.kube-system.svc:443/mutate-v1-service?timeout=10s": no endpoints available for service "aws-load-balancer-webhook-service"
}


# Helm Release Outputs
# output "h1-externaldns_helm_metadata" {
#   description = "Metadata Block outlining status of the deployed release."
#   value = helm_release.external_dns.metadata
# }
output "helm_ver_external-dns" { value = helm_release.external_dns.metadata[0].version }

# kubectl -n kube-system get all,sa | grep external-dns |c
# kubectl -n kube-system get sa external-dns-sa -oyaml |y
# kubectl -n kube-system describe sa external-dns-sa |y
# kubectl -n kube-system logs external-dns-7675965cf9-6swl2 |c
