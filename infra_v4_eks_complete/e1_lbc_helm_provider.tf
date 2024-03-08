# # # HELM Provider

# Datasource: EKS Cluster Auth
data "aws_eks_cluster_auth" "cluster" {
  # name = data.terraform_remote_state.eks.outputs.eks_out.eks_cluster_id
  name = aws_eks_cluster.eks_cluster.id
}

# HELM Provider
provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.eks_cluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.eks_cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

####################
# # test secret output
# resource "aws_ssm_parameter" "foofoo" {
#   name  = "foofoo"
#   type  = "String"
#   #value = aws_eks_cluster.eks_cluster.endpoint
#   #value = base64decode(aws_eks_cluster.eks_cluster.certificate_authority[0].data)
#   value = data.aws_eks_cluster_auth.cluster.token
# }
####################
/*  ALSO HERE: https://registry.terraform.io/providers/hashicorp/helm/latest/docs
provider "helm" {
  kubernetes {
    host                   = var.cluster_endpoint
    cluster_ca_certificate = base64decode(var.cluster_ca_cert)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
      command     = "aws"
    }
  }
}
aws eks get-token --cluster-name raf-eks-cluster --profile dev

*/


/*
█████████████████████████████████████████████████████████████████████████████████
https://support.hashicorp.com/hc/en-us/articles/4408936406803-Kubernetes-Provider-block-fails-with-connect-connection-refused-
Important Information

Single-apply workflows are not a reliable way of deploying Kubernetes infrastructure with Terraform.
 We strongly recommend separating the EKS Cluster from the Kubernetes resources.
 They should be deployed in separate runs, and recorded in separate state files.
 For more details, please refer to this GitHub issue.
  (https://github.com/hashicorp/terraform-provider-kubernetes/issues/1307#issuecomment-873089000)
█████████████████████████████████████████████████████████████████████████████████
*/



