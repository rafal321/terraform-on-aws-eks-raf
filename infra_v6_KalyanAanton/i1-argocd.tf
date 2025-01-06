# ArgoCD Tutorial for Beginners: GitOps CD for Kubernetes #1  (putra)
# https://youtu.be/zGndgdGa1Tc?si=Op-ANzvjuCH-t1tV
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
  version          = "3.35.4" # CHART version
  values           = [file("i2-argocd.yaml")]
  depends_on       = [aws_eks_node_group.eks_ng_private, helm_release.aws_lbc]
  lifecycle { create_before_destroy = false }
}
output "helm_ver_argocd" { value = helm_release.argocd.metadata[0].app_version }
# output "helm_ver_argocd2" { 
#   value = helm_release.argocd
#   sensitive = false
#   } # terraform output helm_ver_argocd2

# kubectl -n monitoring get secret kube-prometheus-stack-grafana -oyaml | awk '/password/ {print $NF}' | base64 -d
# kubectl -n  argocd get secret/argocd-initial-admin-secret -oyaml | grep password | awk '{print $NF}' | base64 -d ; echo
# kubectl get ing -A | sort -rk 3 |c
# ======================================================================
/*
resource "helm_release" "argorollouts" {
  name             = "argorollouts"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-rollouts"
  namespace        = "argo-rollouts"
  create_namespace = true
  version          = "2.37.7"   # CHART version
  values           = [file("i3-argo-rollouts.yaml")]       # http://eric-price.net/posts/2023-12-14-argo-rollouts/#hpayaml
  depends_on       = [aws_eks_node_group.eks_ng_private, helm_release.aws_lbc]
  lifecycle { create_before_destroy = false }
}
output "helm_ver_argorollouts" { value = helm_release.argorollouts.metadata[0].app_version }
*/
# ======================================================================
/* # https://www.youtube.com/watch?v=UgpVX5Sn5OI&list=PLYrn63eEqAzYttcyB6On1oH35O5rxgDt4&index=14
#     walkthrough how to create values.yaml
resource "helm_release" "argoworkflows" {
  name             = "argoworkflows"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-workflows"
  namespace        = "argo"
  create_namespace = true
  # version          = "0.42.7"   # CHART version
  values           = [file("i4-argo-workflows.yaml")]       # http://eric-price.net/posts/2023-12-14-argo-rollouts/#hpayaml
  depends_on       = [aws_eks_node_group.eks_ng_private, helm_release.aws_lbc]
  lifecycle { create_before_destroy = false }
}
output "helm_ver_argoworkflows" { value = helm_release.argoworkflows.metadata[0].app_version }

*/
