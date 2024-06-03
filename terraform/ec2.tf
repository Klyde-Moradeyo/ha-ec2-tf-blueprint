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
  arm_ami =  "ami-03283c89758a063e7"
  intel_ami = "ami-01980876755d1e5ac"

  instance_type_to_ami_map = {
    "t2.small" = local.intel_ami, 
    "t3.small" = local.intel_ami, 
    "t4g.medium" = local.arm_ami, 
    "c6g.medium" = local.arm_ami,
    "t3a.medium" = local.intel_ami 
  }

  # Define weights only for the instance types that are used in overrides
  weighted_capacity_overrides = {
    "t3.micro" = 1,
    "t3.small" = 2
  }
}

module "ec2_server" {
  # source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/ec2-autoscale/aws"
  # version = "0.0.1"
  source = "./ec2-autoscale"

  name                 = var.name

  # EC2 Configuration
  default_ami                  = var.ec2_ami 
  default_instance_type        = var.ec2_type
  key_name = module.ec2_key_pair.key_pair_name
  detailed_monitoring = false
  user_data            = templatefile(var.ec2_user_data_script_path, {
    RDS_HOST = module.rds_instance.db_instance_address
    WORKING_DIR = var.ec2_working_dir
    DB_HOST = module.rds_instance.db_instance_address
    DB_USERNAME = var.rds_username
    DB_PASSWORD = var.rds_password
  })

  # ASG sizing
  desired_capacity = 3
  min_size = 1
  max_size = 5

  # Spot instance configuration
  spot_configuration = {
    enabled = true
    spot_instance_type = "persistent"  
    on_demand_base_capacity = 0 # 1
    on_demand_percentage_above_base_capacity = 0 # 20
    allocation_strategy = "lowest-price"
    max_price = 0.04 # Max price in USD per hour per instance
    instance_pools = length(keys(local.instance_type_to_ami_map))
  }

  # Dynamic
  instance_type_to_ami_map = local.instance_type_to_ami_map

  # Instance type overrides for mixed ASG policy
  instance_type_overrides = [    
    "t2.small", 
    "t3.small", 
    "t4g.medium", 
    "c6g.medium",
    "t3a.medium" 
    ]
  weighted_capacity_overrides = local.weighted_capacity_overrides

  # Network
  vpc_id               = module.vpc.vpc_id
  vpc_zone_identifiers = module.web_private_subnets.subnet_ids
  security_group_ids   = [
    module.ec2_server_sg.security_group_id,
  ]

  # Iam Profile
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.arn

  # Load Balancer
  target_group_arns    = module.load_balancer.target_group_arns

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