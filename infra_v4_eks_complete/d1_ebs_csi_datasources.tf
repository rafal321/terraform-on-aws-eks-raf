data "aws_iam_policy" "ebs_csi_driver_policy" {
  name = "AmazonEBSCSIDriverPolicy"
}


/*

# ==== OLD WAY - there is managed policy now ===============

# Datasource: EBS CSI IAM Policy get from EBS GIT Repo (latest)
data "http" "ebs_csi_iam_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-ebs-csi-driver/master/docs/example-iam-policy.json"

  # Optional request headers
  request_headers = {
    Accept = "application/json"
  }
}

output "ebs_csi_iam_policy_arn" {
  value = aws_iam_policy.ebs_csi_iam_policy.arn
}


# output "ebs_csi_iam_policy" {
#   value = data.http.ebs_csi_iam_policy.response_body
# }


Section 14: AWS EKS EBS CSI Driver
Section 18: AWS EBS CSI EKS Add-On
*/ 