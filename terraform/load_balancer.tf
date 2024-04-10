
##########################
#      Load Balancer     #
##########################
module "load_balancer" {
  source = "./load-balancer"

  name               = var.name
  load_balancer_type = "application"
  subnets            = module.public_subnets.subnet_ids
  security_groups    = [module.load_balancer_sg.security_group_id]
  vpc_id             = module.vpc.vpc_id

  target_groups = [
    {
      name     = "${var.name}-tg"
      port     = 80
      protocol = "HTTP"
      vpc_id   = module.vpc.vpc_id
      health_check = {
        path                = "/"
        interval            = 30
        timeout             = 5
        healthy_threshold   = 5
        unhealthy_threshold = 2
        matcher             = "200"
      }
    }
  ]

  listeners = [
    {
      port            = 80
      protocol        = "HTTP"
      ssl_policy      = ""
      certificate_arn = ""
    }
  ]

  listener_rules = []

  tags = module.tags.tags
}

#######################
#    Security Group   #
#######################
module "load_balancer_sg" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/security-group/aws"
  version = "0.0.1"

  name   = "${var.name}-load-balancer"
  vpc_id = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      description      = "Enable Port 80 access"
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
