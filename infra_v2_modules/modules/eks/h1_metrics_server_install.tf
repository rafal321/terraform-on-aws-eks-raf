
# Install Kubernetes Metrics Server using HELM
# Resource: Helm Release 
resource "helm_release" "metrics_server_release" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"
}

# Helm Release Outputs
# output "metrics_server_helm_metadata" {
#   description = "Metadata Block outlining status of the deployed release."
#   value = helm_release.metrics_server_release.metadata
# }