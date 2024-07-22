# # install generic store csi driver that would integrate
# # secrets with many cloud providers
# # csi-driver Container Storage Interface
# # secrets will be mounted as kubernetes volumes


# resource "helm_release" "secrets_csi_driver" {
#   name = "secrets-store-csi-driver"

#   repository = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
#   chart      = "secrets-store-csi-driver"
#   namespace  = "kube-system"
#   version    = "1.4.3"

#   # MUST be set if you use ENV variables
#   set {
#     name  = "syncSecret.enabled"
#     value = true
#   }
#   # depends_on = [helm_release.efs_csi_driver]
# }

# # we install cloud specific provider
# resource "helm_release" "secrets_csi_driver_aws_provider" {
#   name = "secrets-store-csi-driver-provider-aws"

#   repository = "https://aws.github.io/secrets-store-csi-driver-provider-aws"
#   chart      = "secrets-store-csi-driver-provider-aws"
#   namespace  = "kube-system"
#   version    = "0.3.8"
#   depends_on = [helm_release.secrets_csi_driver]
# }
# # ----------------------------
# # since it is still not suported by plugins we use OpenID Provider

# # this trust policy is used by application thaat needs access to specific secret
# # ["system:serviceaccount:12-example:myapp"]
# data "aws_iam_policy_document" "myapp_secrets" {
#   statement {
#     actions = ["sts:AssumeRoleWithWebIdentity"]
#     effect  = "Allow"

#     condition {
#       test     = "StringEquals"
#       variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
#       values   = ["system:serviceaccount:12-example:myapp"]
#     }

#     principals {
#       identifiers = [aws_iam_openid_connect_provider.eks.arn]
#       type        = "Federated"
#     }
#   }
# }

# # IAM role for that specific application
# resource "aws_iam_role" "myapp_secrets" {
#   name               = "${aws_eks_cluster.eks.name}-myapp-secrets"
#   assume_role_policy = data.aws_iam_policy_document.myapp_secrets.json
# }

# # we need to grant premissions
# resource "aws_iam_policy" "myapp_secrets" {
#   name = "${aws_eks_cluster.eks.name}-myapp-secrets"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "secretsmanager:GetSecretValue",
#           "secretsmanager:DescribeSecret"
#         ]
#         Resource = "*" # "arn:*:secretsmanager:*:*:secret:my-secret-kkargS"
#       }
#     ]
#   })
# }

# # we attrach policy to that application IAM Role
# resource "aws_iam_role_policy_attachment" "myapp_secrets" {
#   policy_arn = aws_iam_policy.myapp_secrets.arn
#   role       = aws_iam_role.myapp_secrets.name
# }

# output "myapp_secrets_role_arn" {
#   value = aws_iam_role.myapp_secrets.arn
# }
