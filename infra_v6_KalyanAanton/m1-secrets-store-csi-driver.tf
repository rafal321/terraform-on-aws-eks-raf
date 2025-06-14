# #  EKS + AWS Secrets Manager Tutorial (Env & Files): AWS EKS Kubernetes Tutorial - Part 10 
# # https://youtu.be/ppJZ4m4t0bI?si=tavMrnuvf9xgXWee

# # https://github.com/kubernetes-sigs/secrets-store-csi-driver

# # generic store csi driver - works many cloud providers

# # NOT FINISHED

# resource "helm_release" "secrets_csi_driver" {
#   name       = "secrets-store-csi-driver"
#   repository = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
#   chart      = "secrets-store-csi-driver"
#   namespace  = "kube-system"
#   version    = "1.4.7"

#   # Must set if use ENV variables
#   # this will create additional rbac policies
#   set {
#     name  = "syncSecret.enabled"
#     value = "true"
#   }
#   depends_on = [aws_eks_node_group.eks_ng_private]
# }

# # specific cloud provider

# resource "helm_release" "secrets_csi_driver_aws_provider" {
#   name       = "secrets-store-csi-driver-aws-provider"
#   repository = "https://kubernetes-sigs.github.io/secrets-store-csi-driver-provider-aws"
#   chart      = "secrets-store-csi-driver-provider-aws"
#   namespace  = "kube-system"
#   version    = "0.3.8"
#   depends_on = [aws_eks_node_group.eks_ng_private]
# }

# # [.1.] I wil use pod identities to access secrets manager - hes using open id connect provider
# # [.2.] we also need role to access secrets manager

# # NOT FINISHED