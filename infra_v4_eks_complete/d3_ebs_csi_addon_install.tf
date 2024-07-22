
resource "aws_eks_addon" "ebs_eks_addon" {
  count = var.enable_ebs_eks_addon ? 1 : 0
  depends_on = [
    aws_iam_role_policy_attachment.ebs_csi_iam_role_policy_attach
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
# EKS AddOn - EBS CSI Driver Outputs
output "ebs_csi_addon_arn" {
  depends_on  = [aws_eks_addon.ebs_eks_addon]
  description = "EKS AddOn - EBS CSI Driver ARN"
  value       = var.enable_ebs_eks_addon ? aws_eks_addon.ebs_eks_addon[0].service_account_role_arn : null
}
output "ebs_csi_addon_version" {
  depends_on  = [aws_eks_addon.ebs_eks_addon]
  description = "EKS AddOn - Version"
  value       = var.enable_ebs_eks_addon ? aws_eks_addon.ebs_eks_addon[0].addon_version : null
}
output "ebs_csi_addon_name" {
  depends_on  = [aws_eks_addon.ebs_eks_addon]
  description = "EKS AddOn - Version"
  value       = var.enable_ebs_eks_addon ? aws_eks_addon.ebs_eks_addon[0].addon_name : null
}

# example 
# output "vue_queue" {
#     value = var.vue_enabled ? aws_sqs_queue.vue_queue.id : null
# }

# output "ebs_eks_addon_id" {
#   description = "EKS AddOn - EBS CSI Driver ID"
#   value       = aws_eks_addon.ebs_eks_addon.id
# }
#  Verification:
#   list all addons:     aws eks list-addons --cluster XXX --profile XXX
#                       kubectl -n kube-system get po,deploy,ds,sa |c