# deploy any helm chart to eks
# https://www.youtube.com/watch?v=0EWsKSdmbz0&list=PLiMWaCMwGJXnKY6XmeifEpjIfkWRo9v2l&index=4

# we use this to authenticate to eks
# this will wait untill cluster is provisoned, safe to run everything together
# data "aws_eks_cluster" "eks" { name = aws_eks_cluster.eks.name }
# data "aws_eks_cluster_auth" "eks" { name = aws_eks_cluster.eks.name }

# # to initialize helm
# provider "helm" {
#   kubernetes {
#     host                   = data.aws_eks_cluster.eks.endpoint
#     cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
#     token                  = data.aws_eks_cluster_auth.eks.token
#   }
# }

# resource "helm_release" "karpenter" {
#   name             = "karpenter"
#   namespace        = "karpenter" # namespace where karpenter will be installed
#   create_namespace = true        # create namespace if it does not exist
#   # repository       = "https://charts.karpenter.sh/"
#   repository = "oci://public.ecr.aws/karpenter/karpenter"
#   chart      = "karpenter"
#   # version          = "0.16.3"
#   version = "0.37.7"

#   set {
#     name  = "clusterName"
#     value = aws_eks_cluster.eks.id
#   }
#   set {
#     name  = "clusterEndpoint" # used to join nodes to eks cluster
#     value = aws_eks_cluster.eks.endpoint
#   }
#   set {
#     name  = "aws.defaultInstanceProfile" # instance profile for karpenter controller
#     value = aws_iam_instance_profile.karpenter_profile.name
#   }
#   depends_on = [aws_eks_node_group.eks_ng_private] # wait for eks node group to be created before installing karpenter
# }

# ==========================================================
# from https://karpenter.sh/docs/getting-started/getting-started-with-karpenter/




# Setup Karpenter in EKS using Terraform (2024)
# https://www.youtube.com/watch?v=VaD-URDFZqM&t=1452s