# https://github.com/tmknom/terraform-aws-rds-mysql/blob/master/main.tf
# https://github.com/terraform-aws-modules/terraform-aws-rds/blob/master/examples/replica-mysql/main.tf


variable "rds_for_mysql_name" {
  description = "var.rds_for_mysql_name"
  type        = string
  default     = "raf"
}
variable "vpc_database_subnet_group_name" {
  description = "var.vpc_database_subnet_group_name"
  type        = string #list(any)
  default     = null
}
variable "vpc_vpc_id" {
  description = "var.vpc_vpc_id"
  type        = string
  default     = null
}
variable "vpc_vpc_cidr_block" {
  description = "var.vpc_vpc_cidr_block"
  type        = string
  default     = null
}
variable "instance_class" {
  description = "var.instance_class"
  type        = string
  default     = "db.t3.medium"
}
variable "replica_db_enable" {
  description = "var.replica_db_enable"
  type        = number
  default     = 0
}
variable "kms_key_id" {
  description = "var.kms_key_id"
  type        = string
  default     = null
}
variable "storage_encrypted" {
  description = "var.storage_encrypted"
  type        = bool
  default     = false
}
# -- cred [2] - ssm_parameter -------------
# {"username":"dbadmin","password":"dbpassword11"}
data "aws_ssm_parameter" "db_creds" {
  name = "rk_terraform_db_cred"
}
locals {
 #db_creds_local = jsondecode(data.aws_ssm_parameter.db_creds.insecure_value)
  db_creds_local = jsondecode(data.aws_ssm_parameter.db_creds.value)
} 

# # -- cred [3]  - secretsmanager ----------
# # -- returns json --------  {"username": "myuser", "password": "mypassword"}
# data "aws_secretsmanager_secret_version" "creds" {
#   secret_id = "db_creds_v3"
# }
# ===============================================================================================
resource "aws_security_group" "rds_for_mysql_sg" {
  name        = "allow-3306"
  description = "Allow DB RAF from vpc"
  vpc_id      = var.vpc_vpc_id
  ingress {
    description = "Allow to all VPC"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.vpc_vpc_cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "rds-sg"
  }
}

# ===============================================================================================
resource "aws_db_instance" "master_db" {
  identifier                          = "${var.rds_for_mysql_name}-rw"
  instance_class                      = var.instance_class
  engine                              = "mysql" # engine_version = "8.0" # if not then latest
  username                            = local.db_creds_local.username
  password                            = local.db_creds_local.password
  db_name                             = null # "usermgmt"
  backup_retention_period             = 5
  allocated_storage                   = 20
  max_allocated_storage               = 100
  storage_type                        = "gp3"
  parameter_group_name                = aws_db_parameter_group.default.name
  apply_immediately                   = true
  db_subnet_group_name                = var.vpc_database_subnet_group_name
  option_group_name                   = aws_db_option_group.default.name
  vpc_security_group_ids              = [aws_security_group.rds_for_mysql_sg.id]
  auto_minor_version_upgrade          = true
  publicly_accessible                 = false
  port                                = 3306
  copy_tags_to_snapshot               = true
  performance_insights_enabled        = false
  iam_database_authentication_enabled = false
  deletion_protection                 = false
  storage_encrypted                   = var.storage_encrypted
  kms_key_id                          = var.kms_key_id
  multi_az                            = false
  maintenance_window                  = "Mon:00:00-Mon:03:00"
  backup_window                       = "03:00-06:00"
  skip_final_snapshot                 = true
  enabled_cloudwatch_logs_exports     = ["error", "slowquery"]
  tags = {
    Name       = "master_dbT"
    Repository = "https://github.com/terraform-aws-modules/terraform-aws-rds"
  }
}
resource "aws_db_instance" "replica_db" {
  count                  = var.replica_db_enable
  identifier             = "${var.rds_for_mysql_name}-ro-${count.index + 1}"
  replicate_source_db    = aws_db_instance.master_db.identifier
  instance_class         = var.instance_class
  max_allocated_storage  = null
  vpc_security_group_ids = [aws_security_group.rds_for_mysql_sg.id]
  tags = {
    Name = "replica_dbT"
  }
}
# ===============================================================================================
resource "aws_cloudwatch_metric_alarm" "master_db_cpu_rds_cw" {
  alarm_name          = "master_db_cpu_rds"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 10
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 900
  statistic           = "Average"
  unit                = "Percent"
  threshold           = 80
  treat_missing_data  = "notBreaching"
  actions_enabled     = false
  alarm_description   = "This metric monitors RDS cpu utilization"
  dimensions          = { DBInstanceIdentifier = aws_db_instance.master_db.identifier }
}
# ===============================================================================================
# https://www.terraform.io/docs/providers/aws/r/db_parameter_group.html
resource "aws_db_parameter_group" "default" {
  name        = "raf-pg"
  family      = "mysql8.0" # DB parameter group
  description = "pg description"
  parameter {
    name  = "time_zone"
    value = "UTC"
  }
  parameter {
    name  = "long_query_time"
    value = 5
  }
  parameter {
    name  = "slow_query_log"
    value = 1
  }
  parameter {
    name  = "max_allowed_packet"
    value = 1073741824
  }
  parameter {
    name  = "log_bin_trust_function_creators"
    value = 1
  }
  parameter {
    name  = "innodb_print_all_deadlocks"
    value = 1
  }
  parameter {
    name  = "binlog_format"
    value = "ROW"
  }
  parameter {
    name         = "performance_schema"
    value        = 1 # Static
    apply_method = "pending-reboot"
  }
  parameter {
    name         = "lower_case_table_names"
    value        = 1 # Static
    apply_method = "pending-reboot"
  }
  tags = {
    dbParmT = "dbParmV"
  }
}
# ===============================================================================================
# NOTE: Any modifications to the db_option_group are set to happen immediately as we default to applying immediately.
# https://www.terraform.io/docs/providers/aws/r/db_option_group.html
resource "aws_db_option_group" "default" {
  engine_name              = "mysql"
  name                     = "option-g-name"
  major_engine_version     = "8.0"
  option_group_description = "opt gr desc"
  tags = {
    optionT = "optionV"
  }
}
# ===============================================================================================
# https://www.terraform.io/docs/providers/aws/r/db_subnet_group.html

# resource "aws_db_subnet_group" "default" {    # created by vpc module
#   name        = "aws-db-subnet-group"
#   subnet_ids  = var.vpc_private_subnets
#   description = "aws_db_subnet_group description"
#   tags = {
#     taggT = "taggV"
#   }
# }

# ===============================================================================================
output "master_db_endpoint" { value = aws_db_instance.master_db.address }

