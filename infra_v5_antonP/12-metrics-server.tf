resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"
  version    = "3.12.1"
  #values = [file("${path.module}/values/metrics-server.yaml")]
  values     = ["${file("12-metrics-server.yaml")}"]
  depends_on = [aws_eks_node_group.eks_ng_private]


  #  set {
  #    name = "replicaCount"
  #    value = 1
  #  }
  # set {
  #   name = "clusterName"
  #   value = aws_eks_cluster.eks.name
  # }
  # set {
  #   name = "securePort"
  #   value = 10250
  # }
  # set {
  #   name = "metricResolution"
  #   value = "15s"
  # }


}