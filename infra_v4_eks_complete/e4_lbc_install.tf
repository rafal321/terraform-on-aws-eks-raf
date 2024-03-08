# Install AWS Load Balancer Controller using HELM
# https://artifacthub.io/packages/helm/aws/aws-load-balancer-controller
# https://github.com/aws/eks-charts/blob/master/stable/aws-load-balancer-controller/values.yaml

# Resource: Helm Release
resource "helm_release" "loadbalancer_controller" {
  depends_on = [aws_iam_role.lbc_iam_role]
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  set {
    name  = "image.repository"
    value = "602401143452.dkr.ecr.eu-west-1.amazonaws.com/amazon/aws-load-balancer-controller"
    # value = "602401143452.dkr.ecr.eu-west-1.amazonaws.com/amazon/aws-load-balancer-controller"
    # Changes based on Region - This is for us-east-1
    # Additional Reference: https://docs.aws.amazon.com/eks/latest/userguide/add-ons-images.html
    # https://artifacthub.io/packages/helm/aws/aws-load-balancer-controller
    # https://github.com/kubernetes-sigs/aws-load-balancer-controller/tree/main/helm/aws-load-balancer-controller --> "ingressClassConfig.default"
  }
  set { #  kubectl get ingressclass -oyaml
    name  = "ingressClassConfig.default"
    value = "true"
  }
  set {
    name  = "serviceAccount.create"
    value = "true"
  }
  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller" # can be auto generated
  }
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.lbc_iam_role.arn
  }
  set {
    name  = "clusterName"
    value = aws_eks_cluster.eks_cluster.id
  }
  #   set {
  #     name  = "vpcId"         # RAF: Redundant                
  #     value = var.vpc_id
  #     #  value = data.terraform_remote_state.eks.outputs.vpc_config[0].vpc_id
  # # The VPC ID for the Kubernetes cluster. Set this manually when your pods are unable to use the metadata service to determine this automatically
  #   }
  set {
    name  = "region"
    value = "${var.aws_region}"
  }
}

# Helm Release Outputs
output "lbc_helm_metadata" {
  description = "Metadata Block outlining status of the deployed release."
  value       = helm_release.loadbalancer_controller.metadata
}

#########
# Section 26. AWS Load Balancer Controller Install using Terraform Helm Provider
#               203. Step-03: Review TFConfigs of Project 02-LBC

# There is a module, I haven't tried that
# https://registry.terraform.io/modules/basisai/lb-controller/aws/latest
