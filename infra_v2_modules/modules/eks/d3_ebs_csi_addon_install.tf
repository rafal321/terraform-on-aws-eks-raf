variable "enable_ebs_eks_addon" {
  description = "If set to true, enable ebs_eks_addon"
  type        = bool
}

resource "aws_eks_addon" "ebs_eks_addon" {
  count = var.enable_ebs_eks_addon ? 1 : 0
  depends_on = [
    aws_iam_role_policy_attachment.ebs_csi_iam_role_policy_attach
    # aws_eks_cluster.eks_cluster
  ]
  cluster_name             = aws_eks_cluster.eks_cluster.id
  addon_name               = "aws-ebs-csi-driver"
  service_account_role_arn = aws_iam_role.ebs_csi_iam_role.arn
}

/*
155. Step-02: Create EBS CSI Add-On Terraform Resource
aws eks list-addons --cluster-name raf-eks-cluster

# Raf: to fix this module.eks.aws_eks_addon.ebs_eks_addon: Still creating... [15m0s elapsed]
 it shoud be created with nodegroup as it waits for nodegroup. when node group is  ready addon creates fast 
*/

###########
# # EKS AddOn - EBS CSI Driver Outputs
# output "ebs_eks_addon_arn" {
#   description = "EKS AddOn - EBS CSI Driver ARN"
#   value       = aws_eks_addon.ebs_eks_addon.arn
# }
# output "ebs_eks_addon_id" {
#   description = "EKS AddOn - EBS CSI Driver ID"
#   value       = aws_eks_addon.ebs_eks_addon.id
# }