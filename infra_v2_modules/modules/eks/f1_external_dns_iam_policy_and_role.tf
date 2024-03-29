# Resource: Create External DNS IAM Policy
resource "aws_iam_policy" "externaldns_iam_policy" {
  name        = "${var.eks_name}-AllowExternalDNSUpdates"
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
          "route53:ListResourceRecordSets"
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
# Resource: Create IAM Role
resource "aws_iam_role" "externaldns_iam_role" {
  name = "${var.eks_name}-externaldns-iam-role"

  # Terraform's "jsonencode" function converts a Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRoleWithWebIdentity"
        Effect    = "Allow"
        Sid       = ""
        Principal = { Federated = "${aws_iam_openid_connect_provider.oidc_provider.arn}" }
        Condition = {
          StringEquals = { # RAF: this creates service account - Trust Relationship
            "${local.aws_iam_oidc_connect_provider_extract_from_arn}:aud" : "sts.amazonaws.com",
            "${local.aws_iam_oidc_connect_provider_extract_from_arn}:sub" : "system:serviceaccount:default:external-dns"
            # NAMESPACE!
          }
        }
      },
    ]
  })
  tags = {
    tag-key              = "${var.eks_name}-AllowExternalDNSUpdates"
    serviceaccount_in_ns = "default"
  }
}

# Associate External DNS IAM Policy to IAM Role
resource "aws_iam_role_policy_attachment" "externaldns_iam_role_policy_attach" {
  policy_arn = aws_iam_policy.externaldns_iam_policy.arn
  role       = aws_iam_role.externaldns_iam_role.name
}

# output "externaldns_iam_role_arn" {
#   description = "External DNS IAM Role ARN"
#   value       = aws_iam_role.externaldns_iam_role.arn
# }
output "eks_external_dns_role" {
  value = aws_iam_role.externaldns_iam_role.name
}