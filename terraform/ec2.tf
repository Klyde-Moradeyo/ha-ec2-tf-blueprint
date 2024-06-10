########################
#     EC2 Key Pair     #
########################
module "ec2_key_pair" {
  source  = "terraform-aws-modules/key-pair/aws"
  version = "2.0.2"

  key_name           = "test-key"
  create_private_key = true
  tags               = module.tags.tags
}

output "ec2_key_pair" {
  value = module.ec2_key_pair.key_pair_name
}

########################
#      EC2 Instance    #
########################
locals {
  instance_type_to_ami_map = {
    "${var.ec2_type}" = { ami = var.ec2_intel_ami, weighted_capacity = 1 } # default ec2-instnace
    "t3.small"        = { ami = var.ec2_intel_ami, weighted_capacity = 1 },
    "t4g.medium"      = { ami = var.ec2_arm_ami, weighted_capacity = 1 },
    "c6g.medium"      = { ami = var.ec2_arm_ami, weighted_capacity = 1 },
    "t3a.medium"      = { ami = var.ec2_intel_ami, weighted_capacity = 1 },
  }
}

module "ec2_server" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/ec2-autoscale/aws"
  version = "0.0.6"

  name = var.name

  # EC2 Configuration
  default_instance_type = var.ec2_type
  key_name              = module.ec2_key_pair.key_pair_name
  detailed_monitoring   = false
  user_data = templatefile(var.ec2_user_data_script_path, {
    RDS_HOST    = module.rds_instance.db_instance_address
    WORKING_DIR = var.ec2_working_dir
    DB_HOST     = module.rds_instance.db_instance_address
    DB_USERNAME = var.rds_username
    DB_PASSWORD = var.rds_password
  })

  # ASG sizing
  desired_capacity = 3
  min_size         = 1
  max_size         = 5

  # Spot instance configuration
  spot_configuration = {
    enabled                                  = true
    on_demand_base_capacity                  = 0 # 1
    on_demand_percentage_above_base_capacity = 0 # 20
    allocation_strategy                      = "lowest-price"
    max_price                                = 0.02 # Max price in USD per hour per instance
    instance_pools                           = length(keys(local.instance_type_to_ami_map))
  }

  # Dynamic
  instance_types_config = local.instance_type_to_ami_map

  # Instance type overrides for mixed ASG policy
  instance_type_overrides = keys(local.instance_type_to_ami_map)

  # Network
  vpc_id               = module.vpc.vpc_id
  vpc_zone_identifiers = module.web_private_subnets.subnet_ids
  security_group_ids = [
    module.ec2_server_sg.security_group_id,
  ]

  # Load Balancer
  target_group_arns = module.load_balancer.target_group_arns

  tags = module.tags.tags
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