#data.terraform_remote_state.eks.outputs.aws_iam_openid_connect_provider_arn
#data.terraform_remote_state.eks.outputs.aws_iam_openid_connect_provider_extract_from_arn

# Resource: Create EBS CSI IAM Policy
resource "aws_iam_policy" "ebs_csi_iam_policy" {
  name        = "${var.eks_name}-EKS_EBS_CSI_Driver_Policy"
  path        = "/"
  description = "EBS CSI IAM Policy"
  #policy = data.http.ebs_csi_iam_policy.body
  policy = data.http.ebs_csi_iam_policy.response_body
}

output "ebs_csi_iam_policy_arn" {
  value = aws_iam_policy.ebs_csi_iam_policy.arn
}

# Resource: Create IAM Role and associate the EBS IAM Policy to it
resource "aws_iam_role" "ebs_csi_iam_role" {
  name        = "${var.eks_name}-ebs-csi-iam-role"
  description = "EBS CSI IAM Role"
  # [Trust Relationship | Trust Policy] Terraform's "jsonencode" function converts a Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Federated = "${aws_iam_openid_connect_provider.oidc_provider.arn}"
        }
        Condition = {
          StringEquals = { # RAF: this creates service account - Trust Relationship
            "${local.aws_iam_oidc_connect_provider_extract_from_arn}:sub" : "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      },
    ]
  })
  tags = {
    tag-key              = "${var.eks_name}-ebs-csi-iam-role"
    serviceaccount_in_ns = "kube-system"
  }
}
# Associate EBS CSI IAM Policy to EBS CSI IAM Role
resource "aws_iam_role_policy_attachment" "ebs_csi_iam_role_policy_attach" {
  policy_arn = aws_iam_policy.ebs_csi_iam_policy.arn
  role       = aws_iam_role.ebs_csi_iam_role.name
}

# output "ebs_csi_iam_role_arn" {
#   description = "EBS CSI IAM Role ARN"
#   value       = aws_iam_role.ebs_csi_iam_role.arn
# }