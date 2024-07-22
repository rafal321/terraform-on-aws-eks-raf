# helm used to deploy metricks server
# Horizontal Pod Autoscaler (HPA) on AWS EKS: AWS EKS Kubernetes Tutorial - Part 4
# https://www.youtube.com/watch?v=0EWsKSdmbz0


# data block will always waits until resource is provisoned
# so it is safe to run everything together
data "aws_eks_cluster" "eks" {
  name = aws_eks_cluster.eks.name
}

data "aws_eks_cluster_auth" "eks" {
  name = aws_eks_cluster.eks.name
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}






# ========================
# output "z-11-a" {
#   value = aws_eks_cluster.eks
#   # sensitive = true
# }

