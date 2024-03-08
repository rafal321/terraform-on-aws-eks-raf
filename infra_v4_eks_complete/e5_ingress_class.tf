# provider "kubernetes" {
#   config_path = "~/.kube/config"
# }
# Resource: Kubernetes Ingress Class
# resource "kubernetes_ingress_class_v1" "ingress_class_default" {
#   depends_on = [helm_release.loadbalancer_controller]
#   metadata {
#     name = "my-aws-ingress-class"
#     annotations = {
#       "ingressclass.kubernetes.io/is-default-class" = "true"
#     }
#   }
#   spec {
#     controller = "ingress.k8s.aws/alb"
#   }
# }

## Additional Note
# 1. You can mark a particular IngressClass as the default for your cluster.
# 2. Setting the ingressclass.kubernetes.io/is-default-class annotation to true on an IngressClass resource will ensure that new Ingresses without an ingressClassName field specified will be assigned this default IngressClass.
# 3. Reference: 
#   https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.6/guide/ingress/ingress_class/
#   https://kubernetes.io/docs/concepts/services-networking/ingress/#default-ingress-class

# see notes in e1_lbc_helm_provider.tf

/*
########################
++++++
apiVersion: networking.k8s.io/v1
kind: IngressClass
metadata:
  name: my-aws-ingress-class
  annotations:
    ingressclass.kubernetes.io/is-default-class: "true"
spec:
  controller: ingress.k8s.aws/alb
++++++
cat <<EOF | kubectl create -f -
apiVersion: networking.k8s.io/v1
kind: IngressClass
metadata:
  name: my-aws-ingress-class
  annotations:
    ingressclass.kubernetes.io/is-default-class: "true"
spec:
  controller: ingress.k8s.aws/alb
EOF
++++++


## Additional Note
# 1. You can mark a particular IngressClass as the default for your cluster.
# 2. Setting the ingressclass.kubernetes.io/is-default-class annotation to true on an IngressClass resource will ensure that new Ingresses without an spec.ingressClassName field specified will be assigned this default IngressClass.
# 3. Reference: https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.3/guide/ingress/ingress_class/




# /home/ec2-user/aws-eks-kubernetes-masterclass/08-NEW-ELB-Application-LoadBalancers/08-01-Load-Balancer-Controller-Install
# Section 10: ALB Ingress  - Install AWS LB Controller Install on AWS EKS Cluster
# 91. Step-07 Introduction to Kubernetes Ingress Class Resource pdf-v8-111
*/