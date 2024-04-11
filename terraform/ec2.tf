########################
#      EC2 Instance    #
########################
module "ec2_server" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/ec2-autoscale/aws"
  version = "0.0.1"

  name                 = var.name
  ami                  = var.ec2_ami
  instance_type        = var.ec2_type
  vpc_id               = module.vpc.vpc_id
  security_group_ids   = [module.ec2_server_sg.security_group_id]
  vpc_zone_identifiers = module.private_subnets.subnet_ids
  target_group_arns    = module.load_balancer.target_group_arns
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.arn
  user_data            = var.ec2_userdata

  # Instance Count
  desired_capacity = 1
  max_size = 5
  min_size = 1

  tags = module.tags.tags
}

############################
#   EC2 Instance Profile   #
############################
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.name}-ec2-profile"
  role = module.ec2_iam_role.iam_role_name
}

#######################
#    Security Group   #
#######################
module "ec2_server_sg" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/security-group/aws"
  version = "0.0.1"

  name   = "${var.name}-ec2"
  vpc_id = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      description      = "Enable Port 22 SSH access"
      self             = true
    },
    {
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      description      = "Enable Port 80 access (for test)"
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