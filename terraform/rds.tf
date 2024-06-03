module "rds_instance" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/rds/aws"
  version = "0.0.1"

  name                      = var.name
  instance_class            = var.rds_instance_class
  allocated_storage         = var.rds_allocated_storage
  engine                    = var.rds_engine
  engine_version            = var.rds_engine_version
  username                  = var.rds_username
  password                  = var.rds_password
  subnet_ids                = module.db_private_subnets.subnet_ids
  vpc_security_group_ids    = [ module.rds_sg.security_group_id ]
  multi_az                  = false
  storage_encrypted         = true

  tags = module.tags.tags
}

#######################
#    Security Group   #
#######################
module "rds_sg" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/security-group/aws"
  version = "0.0.1"

  name   = "${var.name}-rds"
  vpc_id = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port        = 5432
      to_port          = 5432
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      description      = "Enable Port 5432 access"
      self             = true
    }
  ]

  egress_rules = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      description      = "Allow all outbound traffic"
    }
  ]

  tags = module.tags.tags
}