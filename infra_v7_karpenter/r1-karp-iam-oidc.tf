# ### [1] establish trust
data "tls_certificate" "eks" {
  url = aws_eks_cluster.eks.identity[0].oidc[0].issuer # get certificate URL from EKS cluster OIDC issuer
}
resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint] # use the SHA1 fingerprint of the certificate
  url             = data.tls_certificate.eks.url
  tags            = { Name = "${local.eks_name}-${local.env}-cluster" }
}

# ## [2] trust policy to allow service account to assume IAM role

data "aws_iam_policy_document" "karpenter_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:karpenter:karpenter"] # to karpenter namespace:service account
    }
    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
}
# # karpenter controller role and attach this policy to it
resource "aws_iam_role" "karpenter_controller_role" {
  assume_role_policy = data.aws_iam_policy_document.karpenter_assume_role_policy.json
  name               = "rk-KarpenterControllerRole"
  tags               = { Name = "${local.eks_name}-${local.env}-role" }
}

# # set of premissions we need to grant to karpenter controller

resource "aws_iam_policy" "karpenter_controller_policy" {
  name        = "rk-KarpenterControllerPolicy"
  description = "Policy for Karpenter Controller to manage EKS nodes"
  policy      = file("./karpenter-controller-trust-policy.json") # path to your policy JSON file
}
# attach the policy to the role
resource "aws_iam_role_policy_attachment" "karpenter_controller_policy_attachment" {
  role       = aws_iam_role.karpenter_controller_role.name
  policy_arn = aws_iam_policy.karpenter_controller_policy.arn
}

# we use the same role - karpenter will use this role to attach to instances it creates
resource "aws_iam_instance_profile" "karpenter_profile" {
  name = "rk-KarpenterInstanceProfile"
  role = aws_iam_role.karpenter_controller_role.name
}


