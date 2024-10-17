# https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html

# RAF I don't know if I really need that as it is installed by default
# Remember that the VPC CNI plugin is typically installed by default when you create an EKS cluster. This method is useful if you need to manage it explicitly or if you're upgrading an existing installation.

resource "aws_eks_addon" "vpc_cni" {
  cluster_name  = aws_eks_cluster.eks.id
  addon_name    = "vpc-cni"
  addon_version = "v1.18.5-eksbuild.1" # Replace with the desired version
}

#===============================================================

# Do I need IAM role and policy for Amazon VPC CNI plugin to work?

# Yes, you do need an IAM role and policy for the Amazon VPC CNI plugin to work properly. Here's why:

#     IAM Permissions: The Amazon VPC CNI plugin requires specific AWS Identity and Access Management (IAM) permissions to manage IP addresses and network interfaces for your EKS cluster.

#     Default Configuration: By default, the VPC CNI plugin uses the Amazon EKS node IAM role, which typically has the necessary permissions.

#     Recommended Approach: However, it's strongly recommended to create a separate IAM role specifically for the VPC CNI plugin. This follows the principle of least privilege and improves security.

#     Policy Requirements:
#         For IPv4 clusters, you can use the AWS-managed policy
#         AmazonEKS_CNI_Policy
#         .
#         For IPv6 clusters, you need to create a custom IAM policy with specific permissions.

#     Service Account: The VPC CNI plugin creates a Kubernetes service account named
#     aws-node
#     . This service account should be associated with the IAM role that has the necessary permissions.

#     IRSA (IAM Roles for Service Accounts): It's recommended to use IRSA to associate the IAM role with the
#     aws-node
#     service account. This provides a more secure way to manage permissions.

# To set this up properly, you would typically:

#     Create an IAM role with the appropriate policy.
#     Associate this role with the
#     aws-node
#     service account using IRSA.
#     Ensure the EKS cluster has an OIDC provider configured to support IRSA.

# If you're setting up a new cluster or add-on, you can specify the IAM role during the creation process. For existing setups, you may need to update the configuration to use a dedicated IAM role for the VPC CNI plugin.

# Remember to refer to the latest AWS documentation for the most up-to-date and detailed instructions on configuring IAM roles and policies for the Amazon VPC CNI plugin.


