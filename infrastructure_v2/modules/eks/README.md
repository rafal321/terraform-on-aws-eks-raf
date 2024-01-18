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
