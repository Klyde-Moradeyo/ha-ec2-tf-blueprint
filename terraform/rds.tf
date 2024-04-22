module "rds_instance" {
  source = "./rds"

  name                      = var.name
  instance_class            = var.instance_class
  allocated_storage         = var.allocated_storage
  engine                    = var.engine
  engine_version            = var.engine_version
  username                  = var.username
  password                  = var.password
  subnet_ids                = module.web_private_subnets.subnet_ids
  vpc_security_group_ids    = []
  multi_az                  = false # true
  storage_encrypted         = true

  tags = module.tags.tags
}
