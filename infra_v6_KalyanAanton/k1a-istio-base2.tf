#  Istio Tutorial (Service Mesh - Ingress Gateway - Virtual Service - Gateway - Ingress - mTLS)  (Anton Putra)
# https://www.youtube.com/watch?v=H4YIKwAQMKk

# Amazon EKS Cluster w/ Istio
# https://aws-ia.github.io/terraform-aws-eks-blueprints/patterns/istio/

# helm repo add istio https://istio-release.storage.googleapis.com/charts
# helm repo update
# helm search repo istio/base       to see the version
# install manually:
# █ helm install my-istio-base-release -n istio-system --create-namespace istio/base --set global.istioNamespace=istio-system

/*
# GIT
# https://github.com/antonputra/tutorials/tree/main/lessons/155/istio-terraform

resource "helm_release" "istio_base" {
  name = "my-istio-base-release"

  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "base" # what helm chart you want to use
  namespace        = "istio-system"
  create_namespace = true
  version          = "1.24.1"  # "1.17.1"

  set {
    name  = "global.istioNamespace"
    value = "istio-system"
  }
  depends_on = [aws_eks_node_group.eks_ng_private]
}
##################################################################
##################################################################
# https://github.com/antonputra/tutorials/blob/main/lessons/155/istio-terraform/2-istiod.tf
# helm repo add istio https://istio-release.storage.googleapis.com/charts
# helm repo update
# helm search repo istio/istiod         to see the version
# install manually:
# █ helm install my-istiod-release -n istio-system --create-namespace istio/istiod --set telemetry.enabled=true --set global.istioNamespace=istio-system

# istiod contains: Pilot|Citadel|Gallery
resource "helm_release" "istiod" {
  name             = "my-istiod-release"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "istiod"
  namespace        = "istio-system"
  create_namespace = true
  version          = "1.24.1"  # "1.17.1"
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

#/*
# Istio Service Mesh on AWS EKS | Step by Step Guide to install Istio Service Mesh on Kubernetes
# https://www.youtube.com/watch?v=LFit-K1LMx0


# helm repo add istio https://istio-release.storage.googleapis.com/charts
# helm repo update
# helm search repo istio/gateway        to see the version
# █ helm install gateway -n istio-ingress --create-namespace istio/gateway

# /*
resource "helm_release" "gateway" {
  name = "ingressgateway" # "gateway"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "gateway"
  namespace        = "istio-ingress"
  create_namespace = true
  version          = "1.24.1"  # "1.17.1"       # this creates NLB 
  depends_on = [helm_release.istio_base, helm_release.istiod]
}

*/

# KIALI kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.24/samples/addons/kiali.yaml

# helm search repo istio
# NAME                                    CHART VERSION   APP VERSION     DESCRIPTION                                       
# bitnami/wavefront-adapter-for-istio     2.0.6           0.1.5           DEPRECATED Wavefront Adapter for Istio is an ad...
# istio/istiod                            1.24.1          1.24.1          Helm chart for istio control plane                
# istio/istiod-remote                     1.23.3          1.23.3          Helm chart for a remote cluster using an extern...
# istio/ambient                           1.24.1          1.24.1          Helm umbrella chart for ambient                   
# istio/base                              1.24.1          1.24.1          Helm chart for deploying Istio cluster resource...
# istio/cni                               1.24.1          1.24.1          Helm chart for istio-cni components               
# istio/gateway                           1.24.1          1.24.1          Helm chart for deploying Istio gateways           
# istio/ztunnel                           1.24.1          1.24.1          Helm chart for istio ztunnel components 
# ================================================================================================================================
# helm ls -n istio-system
# NAME                    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART           APP VERSION
# my-istio-base-release   istio-system    1               2024-12-13 12:17:28.134418663 +0000 UTC deployed        base-1.24.1     1.24.1
# my-istiod-release       istio-system    1               2024-12-13 12:17:37.834269727 +0000 UTC deployed        istiod-1.24.1   1.24.1

# Istio sample app 2025-06-08
# kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.26/samples/bookinfo/platform/kube/bookinfo.yaml
# kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.26/samples/bookinfo/platform/kube/bookinfo-versions.yaml
