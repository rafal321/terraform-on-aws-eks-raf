# ==== vpc_outputs.tf ====
output "vpc_subnets_database" { value = module.vpc.database_subnets }
output "vpc_subnets_infra" { value = module.vpc.intra_subnets }
output "vpc_subnets_private" { value = module.vpc.private_subnets }
output "vpc_subnets_public" { value = module.vpc.public_subnets }
output "vpc_id" { value = module.vpc.vpc_id }
output "vpc_owner_id" { value = module.vpc.vpc_owner_id }
output "vpc_arn" { value = module.vpc.vpc_arn }
output "vpc_cidr_block" { value = module.vpc.vpc_cidr_block }
#output "vpc_private_subnet_arns" { value = module.vpc.private_subnet_arns }
#output "vpc_public_subnet_arns" { value = module.vpc.public_subnet_arns }
#output "vpc_intra_subnet_arns" { value = module.vpc.infra_subnet_arns }
