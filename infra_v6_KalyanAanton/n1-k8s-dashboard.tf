# https://github.com/kubernetes/dashboard

# nstruction how to install:
# https://artifacthub.io/packages/helm/k8s-dashboard/kubernetes-dashboard

## Add kubernetes-dashboard repository
#       helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/

## Deploy a Helm Release named "kubernetes-dashboard" using the kubernetes-dashboard chart
#       helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard

# Uninstall
#       helm delete kubernetes-dashboard --namespace kubernetes-dashboard
# --------------------------------------------------------------
# Access
# [1] kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443
# [2] https://localhost:8443

#   To generate a token run the following command
# [3]       kubectl -n kubernetes-dashboard create token admin-user
#    Please note for the ANA dev and perf clusters it was necessary to run:
# [4]       kubectl -n kube-system create token admin
# --------------------------------------------------------------
/*
resource "helm_release" "kubernetes-dashboard" {
  name             = "kubernetes-dashboard"
  repository       = "https://kubernetes.github.io/dashboard/"
  chart            = "kubernetes-dashboard"
  namespace        = "kubernetes-dashboard"
  create_namespace = true
  # version          = "7.10.3" # CHART version
  depends_on       = [aws_eks_node_group.eks_ng_private, helm_release.aws_lbc]
  lifecycle { create_before_destroy = false }

    set {
    name  = "annotations.nginx.ingress.kubernetes.io/backend-protocol"
    value = "HTTP"
  }

}
output "helm_ver_kubernetes-dashboard" { value = helm_release.kubernetes-dashboard.metadata[0].version }
*/
# kubectl get endpoints -n kubernetes-dashboard |c
# helm show values kubernetes-dashboard/kubernetes-dashboard
# helm show values kubernetes-dashboard/kubernetes-dashboard | yq .image.tag (to show specific values)