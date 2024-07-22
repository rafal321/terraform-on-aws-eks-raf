# I've skipped this for now
# Add IAM User & IAM Role to AWS EKS: AWS EKS Kubernetes Tutorial - Part 3
# https://www.youtube.com/watch?v=6COvT1Zu9o0



/*
# this is important API related, no more aws_config !!
resource "aws_eks_access_entry" "developer" {
  cluster_name = aws_eks_cluster.eks.name
  principal_arn = aws_iam_user.developer.arn
  kubernetes_groups = ["my-viewer"]
}

*/