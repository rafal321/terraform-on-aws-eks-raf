/*
# YT - Kubernetes Canary Deployment (Manual vs Automated)
# https://youtu.be/fWe6k4MmeSg?si=-PB_lXjBc5stBXqP

# 2-istio-base.tf
resource "helm_release" "istio_base" {
  depends_on       = [aws_eks_node_group.eks_ng_private]
  name             = "istio-base"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "base"
  namespace        = "istio-system"
  create_namespace = true
  version          = "1.18.2"
}
# ------------------------------------------------------------------------
# 3-istiod.tf
resource "helm_release" "istiod" {
  depends_on       = [helm_release.istio_base]
  name             = "istiod"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "istiod"
  namespace        = "istio-system"
  create_namespace = true
  version          = "1.18.2"
  set {
    name  = "telemetry.enabled"
    value = "true"
  }
}
# ------------------------------------------------------------------------
#4-flagger.tf
resource "helm_release" "flagger" {
  depends_on       = [aws_eks_node_group.eks_ng_private]
  name             = "flagger"
  repository       = "https://flagger.app"
  chart            = "flagger"
  namespace        = "flagger"
  create_namespace = true
  version          = "1.32.0"
  set {
    name  = "crd.create"
    value = "false"
  }
  set {
    name  = "meshProvider"
    value = "istio"
  }
  set {
    name  = "metricsServer"
    value = "http://prometheus-operated.monitoring:9090"
  }
}
# ------------------------------------------------------------------------
# 5-flagger-loadtester.tf
resource "helm_release" "loadtester" {
  depends_on       = [helm_release.flagger]
  name             = "loadtester"
  repository       = "https://flagger.app"
  chart            = "loadtester"
  namespace        = "flagger"
  create_namespace = true
  version          = "0.28.1"
}

# ------------------------------------------------------------------------
# https://repost.aws/knowledge-center/eks-cluster-kubernetes-dashboard


resource "helm_release" "kubernetes_dashboard" {
  depends_on       = [helm_release.flagger]
  name             = "kubernetes-dashboard"
  repository       = "https://kubernetes.github.io/dashboard/"
  chart            = "kubernetes-dashboard"
  namespace        = "kubernetes-dashboard"
  create_namespace = true
  version          = "7.4.0"
}
output "helm_ver_kubernetes_dashboard" { value = helm_release.kubernetes_dashboard.version }

*/