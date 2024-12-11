# deploy any helm chart to eks
# https://www.youtube.com/watch?v=0EWsKSdmbz0&list=PLiMWaCMwGJXnKY6XmeifEpjIfkWRo9v2l&index=4

# we use this to authenticate to eks
# this will wait untill cluster is provisoned, safe to run everything together
data "aws_eks_cluster" "eks" { name = aws_eks_cluster.eks.name }
data "aws_eks_cluster_auth" "eks" { name = aws_eks_cluster.eks.name }

# to initialize helm
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}
