# 0-data.tf -> vpc

data "aws_caller_identity" "current" {}
output "vpc_aws_account_id" { value = data.aws_caller_identity.current.account_id }
