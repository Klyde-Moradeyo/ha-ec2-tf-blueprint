##########################
#     Naming Config      #
##########################
module "resource_name_prefix" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/resource-name-prefix/aws"
  version = "0.0.1"

  name = var.name
  tags = var.tags
}

##########################
#          RDS           #
##########################
resource "aws_db_instance" "db" {
  identifier              = "${module.resource_name_prefix.resource_name}-rds"
  instance_class          = var.instance_class
  allocated_storage       = var.allocated_storage
  engine                  = var.engine
  engine_version          = var.engine_version
  username                = var.username
  password                = var.password
  parameter_group_name    = length(var.db_parameters) > 0 ? aws_db_parameter_group.db_param_group[0].name : null
  db_subnet_group_name    = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids  = var.vpc_security_group_ids
  multi_az                = var.multi_az
  storage_encrypted       = var.storage_encrypted
  backup_retention_period = var.backup_retention_period
  skip_final_snapshot  = var.skip_final_snapshot
  tags                    = var.tags
}

resource "aws_db_parameter_group" "db_param_group" {
  count       = length(var.db_parameters) > 0 ? 1 : 0
  name        = "${module.resource_name_prefix.resource_name}-rds-params"
  family      = "${module.resource_name_prefix.resource_name}-param-family"
  description = "${module.resource_name_prefix.resource_name} RDS params"

  dynamic "parameter" {
    for_each = var.db_parameters

    content {
      name  = parameter.key
      value = parameter.value
    }
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${module.resource_name_prefix.resource_name}-subnet-grp"
  subnet_ids = var.subnet_ids
}
