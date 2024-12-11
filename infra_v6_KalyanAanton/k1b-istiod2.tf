# https://github.com/antonputra/tutorials/blob/main/lessons/155/istio-terraform/2-istiod.tf
# helm repo add istio https://istio-release.storage.googleapis.com/charts
# helm repo update
# install manually:
# helm install my-istiod-release -n istio-system --create-namespace istio/istiod --set telemetry.enabled=true --set global.istioNamespace=istio-system

# istiod contains: Pilot|Citadel|Gallery
resource "helm_release" "istiod" {
  name = "my-istiod-release"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "istiod"
  namespace        = "istio-system"
  create_namespace = true
  version          = "1.17.1"
  set {
    name  = "telemetry.enabled"
    value = "true"
  }
  set {
    name  = "global.istioNamespace"
    value = "istio-system"
  }
  set {
    name  = "meshConfig.ingressService"
    value = "istio-gateway"
  }
  set {
    name  = "meshConfig.ingressSelector"
    value = "gateway"
  }
  depends_on = [helm_release.istio_base]
}