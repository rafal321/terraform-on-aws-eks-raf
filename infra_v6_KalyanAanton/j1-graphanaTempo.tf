# # [1] need helm provider configured
# # https://youtu.be/ZIN7H00ulQw?si=_cSzIcx2KBfywc9_

# [5] KUBE-PROMETHEUS-STACK --------------------
# https://youtu.be/kCWAwXFnYic?si=k6V-yTiZueAvEaTa (38:10)
# helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
# helm repo list
# helm search repo prometheus-community |c
# helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace
/*
resource "helm_release" "prometheus_stack" {
  depends_on = [aws_eks_node_group.eks_ng_private, helm_release.aws_lbc]
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "monitoring"
  #version          = "65.3.1" # CHART VERSION - If this is not specified, the latest version is installed.
  create_namespace = true
}
output "helm_ver_prometheus-stack" { value = helm_release.prometheus_stack.version }
*/








#############################################################################################################################
# # [2] GRAPHANA TEMPO --------------
# # Install manually
# # helm repo add grafana https://grafana.github.io/helm-charts
# # helm repo update
# # helm search repo grafana
# # helm install tempo --namespace monitoring --create-namespace --version 1.6.2 --values terraform/values/tempo.yaml grafana/tempo

# resource "helm_release" "tempo" {
#   depends_on = [aws_eks_node_group.eks_ng_private]
#   name       = "tempo"

#   repository       = "https://grafana.github.io/helm-charts"
#   chart            = "tempo"
#   namespace        = "monitoring"
#   version          = "1.6.2" # CHART VERSION - If this is not specified, the latest version is installed.
#   create_namespace = true

#   values = [file("j5-tempo.yaml")]
# }

# # [3] GRAPHANA --------------------
# # Install manually
# # helm repo add grafana https://grafana.github.io/helm-charts
# # helm repo update
# # helm install grafana --namespace monitoring --create-namespace --version 6.60.6 --values terraform/values/grafana.yaml grafana/grafana
# resource "helm_release" "grafana" {
#   depends_on = [aws_eks_node_group.eks_ng_private]
#   name       = "grafana"

#   repository       = "https://grafana.github.io/helm-charts"
#   chart            = "grafana"
#   namespace        = "monitoring"
#   version          = "6.60.6" # CHART VERSION - If this is not specified, the latest version is installed.
#   create_namespace = true

#   values = [file("j6-grafana.yaml")]
# }

# # [4] PROMETHEUS --------------------
# resource "helm_release" "prometheus" {
#   depends_on = [aws_eks_node_group.eks_ng_private]
#   name       = "prometheus"

#   repository       = "https://grafana.github.io/helm-charts"
#   chart            = "grafana"
#   namespace        = "monitoring"
#   version          = "6.60.6" # CHART VERSION - If this is not specified, the latest version is installed.
#   create_namespace = true
# }
# output "helm_ver_tempo" { value = helm_release.tempo.version }
# output "helm_ver_grafana" { value = helm_release.grafana.version }

# # ---------------------------------------------------------------------------------
# # helm search repo grafana |c
# # NAME                                            CHART VERSION   APP VERSION             DESCRIPTION
# # bitnami/grafana                                 11.3.22         11.2.2                  Grafana is an open source metric analytics and ...
# # [...]
# # grafana/tempo                                   1.10.3          2.5.0                   Grafana Tempo Single Binary Mode
# # [...]
# # prometheus-community/kube-prometheus-stack      65.3.1          v0.77.1                 kube-prometheus-stack collects Kubernetes manif...
# # prometheus-community/prometheus-druid-exporter  1.1.0           v0.11.0                 Druid exporter to monitor druid metrics with Pr...


