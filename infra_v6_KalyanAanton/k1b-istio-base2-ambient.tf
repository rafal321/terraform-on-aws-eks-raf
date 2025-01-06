# Based on official docks
# https://istio.io/latest/docs/ambient/install/helm/

# helm repo add istio https://istio-release.storage.googleapis.com/charts
# helm repo update

# helm install istio-base istio/base -n istio-system --create-namespace --wait

#       kubectl get crd gateways.gateway.networking.k8s.io &> /dev/null || \
#         { kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.0/standard-install.yaml; }

# helm install istiod istio/istiod --namespace istio-system --set profile=ambient --wait
# helm install istio-cni istio/cni -n istio-system --set profile=ambient --wait
# helm install ztunnel istio/ztunnel -n istio-system --wait
# helm install istio-ingress istio/gateway -n istio-ingress --create-namespace --wait
/*
resource "helm_release" "istio_base" {
  name = "my-istio-base-release"

  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "base" # what helm chart you want to use
  namespace        = "istio-system"
  create_namespace = true
  version          =  "1.17.1"  #"1.24.1"

  set {
    name  = "global.istioNamespace"
    value = "istio-system"
  }
  depends_on = [aws_eks_node_group.eks_ng_private]
}

resource "helm_release" "istiod" {
  name             = "my-istiod-release"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "istiod"
  namespace        = "istio-system"
  create_namespace = true
  version          = "1.24.1"     # https://artifacthub.io/packages/helm/istio-official/ambient  RAF SEE THIS
  # set {
  #   name  = "profile"
  #   value = "ambient"
  # }
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
resource "helm_release" "istio_cni" {
  name             = "my-cni-release"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "cni"
  namespace        = "istio-system"
  create_namespace = true
  version          = "1.24.1"
  set {
    name  = "profile"
    value = "ambient"
  }
  depends_on = [helm_release.istiod]
}
resource "helm_release" "istio_ztunnel" {   # we collect metrics here too??
  name             = "my-ztunnel-release"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "ztunnel"
  namespace        = "istio-system"
  create_namespace = true
  version          = "1.24.1"
  depends_on       = [helm_release.istio_base]
}
resource "helm_release" "gateway" {         # Waypoint proxies are deployed using Kubernetes Gateway resources. (pod at namespace level - scaleable)
  name             = "gateway"              # this creates AWS - NLB 
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "gateway"
  namespace        = "istio-ingress"
  create_namespace = true
  version          = "1.24.1"
  depends_on       = [helm_release.istio_base]
}
*/
# helm ls -n istio-system |c
# NAME                    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART           APP VERSION
# my-cni-release          istio-system    1               2024-12-13 20:22:59.476893716 +0000 UTC deployed        cni-1.24.1      1.24.1
# my-istio-base-release   istio-system    1               2024-12-13 19:47:02.684219376 +0000 UTC deployed        base-1.24.1     1.24.1
# my-istiod-release       istio-system    1               2024-12-13 20:15:59.179897526 +0000 UTC deployed        istiod-1.24.1   1.24.1
# my-ztunnel-release      istio-system    1               2024-12-13 20:23:02.914129769 +0000 UTC deployed        ztunnel-1.24.1  1.24.1

# kubectl get all |c
# NAME                          READY   STATUS    RESTARTS   AGE
# pod/istio-cni-node-swr8p      1/1     Running   0          11m
# pod/istio-cni-node-zbc4n      1/1     Running   0          11m
# pod/istiod-566f9db98b-8mzrz   1/1     Running   0          18m
# pod/ztunnel-ftpwk             1/1     Running   0          11m
# pod/ztunnel-mdwnz             1/1     Running   0          11m


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


# Istio Ambient Mesh Launch Demo
# https://www.youtube.com/watch?v=nupRBh9Iypo
# |# kubectl debug -it -n istio-system ztunnel-ftpwk  --image=nicolaka/netshoot --image-pull-policy=Always          SHARK 
# |# ztunnel-ftpwk ~ termshark -i eth0

# https://istio.io/latest/docs/ambient/architecture/data-plane/
# In ambient mode, workloads can fall into 3 categories:

#    - Out of Mesh: a standard pod without any mesh features enabled. Istio and the ambient data plane are not enabled.
#    - In Mesh: a pod that is included in the ambient data plane, and has traffic intercepted at the Layer 4 level by ztunnel. In this mode, L4 policies can be enforced for pod traffic. This mode can be enabled by setting the istio.io/dataplane-mode=ambient label. See labels for more details.
#    - In Mesh, Waypoint enabled: a pod that is in mesh and has a waypoint proxy deployed. In this mode, L7 policies can be enforced for pod traffic. This mode can be enabled by setting the istio.io/use-waypoint label. See labels for more details.

# A Not-so-Scary Way to Add Istio to Your Platform, Step by Step - John Keates, Wehkamp Retail Group
# https://youtu.be/8pgn5UaHkmQ?si=3WEmAhPpTt9TDJ8W		Great What istio is - what you need
# https://youtu.be/gP_hB97oVzU?si=0-5RZnZpBcEhR7eq
