resource "aws_eks_addon" "ebs_eks_addon" {
  depends_on               = [
    aws_iam_role_policy_attachment.ebs_csi_iam_role_policy_attach,
    aws_eks_cluster.eks_cluster   # Raf: to fix this module.eks.aws_eks_addon.ebs_eks_addon: Still creating... [15m0s elapsed]
  ]
  cluster_name             = aws_eks_cluster.eks_cluster.id
  addon_name               = "aws-ebs-csi-driver"
  service_account_role_arn = aws_iam_role.ebs_csi_iam_role.arn
}

/*
155. Step-02: Create EBS CSI Add-On Terraform Resource
aws eks list-addons --cluster-name raf-eks-cluster
*/