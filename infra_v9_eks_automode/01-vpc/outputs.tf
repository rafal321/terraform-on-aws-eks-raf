output "aws_account_id" { value = data.aws_caller_identity.current.account_id }
output "aws_region" { value = var.region }
output "vpc_id" { value = module.vpc.vpc_id }

output "private_subnets" { value = module.vpc.private_subnets }
output "public_subnets" { value = module.vpc.public_subnets }
output "intra_subnets" { value = module.vpc.intra_subnets }
