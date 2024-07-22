resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"
  version    = "3.12.1"
  #values = [file("${path.module}/values/metrics-server.yaml")]
  values     = ["${file("c2-metrics-server.yaml")}"]
  depends_on = [aws_eks_node_group.eks_ng_private]
}

# Deploy Kubernetes Dashboard with Metrics Server using Terraform and Helm on Docker Desktop
# https://dev.to/garis_space/terraform-and-helm-to-deploy-the-kubernetes-dashboard-1dpl