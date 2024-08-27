#/*
# # this is all we need to configure this provider

# 1 extract certificate from eks cluster
data "tls_certificate" "eks" {
  url = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

# 2 and use it to create openid provider on aws side in IAM
resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}
# here we need it for efs



#output "zz1" {  value = data.tls_certificate.eks}
#output "zz2" {  value = aws_iam_openid_connect_provider.eks}
#*/