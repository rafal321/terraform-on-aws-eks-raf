# already have helm provider

# [1] install using helm chart
# manually:
# helm install argocd -n argocd --create-namespace argo/argo-cd --version 3.35.4 -f values_argocd.yaml
# with terraform:
resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "3.35.4"
  values           = [file("i2-argocd.yaml")]
  depends_on = [aws_eks_node_group.eks_ng_private]
}
output "helm_ver_argocd" {
  value = helm_release.argocd.version
}

# ingress example
