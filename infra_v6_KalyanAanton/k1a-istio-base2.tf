#  Istio Tutorial (Service Mesh - Ingress Gateway - Virtual Service - Gateway - Ingress - mTLS) 
# https://www.youtube.com/watch?v=H4YIKwAQMKk


# helm repo add istio https://istio-release.storage.googleapis.com/charts
# helm repo update
# install manually:
# helm install my-istio-base-release -n istio-system --create-namespace istio/base --set global.istioNamespace=istio-system

# GIT
# https://github.com/antonputra/tutorials/tree/main/lessons/155/istio-terraform

resource "helm_release" "istio_base" {
  name = "my-istio-base-release"

  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "base"             # what helm chart you want to use
  namespace        = "istio-system"
  create_namespace = true
  version          = "1.17.1"

  set {
    name  = "global.istioNamespace"
    value = "istio-system"
  }
  depends_on = [aws_eks_node_group.eks_ng_private]
}
