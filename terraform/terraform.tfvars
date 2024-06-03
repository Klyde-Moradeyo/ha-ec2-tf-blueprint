# name
name = "election-web-app"

# region
aws_region = "eu-west-2"

# Tags
project     = "election-web-app"
client      = "public"
owner       = "Klyde-Moradeyo"
namespace   = "terraform-template"
environment = "dev"

# Vpc
vpc_cidr = "10.0.0.0/16"

# Subnet
public_subnet_cidrs = [
  "10.0.31.0/24",
  "10.0.32.0/24",
  "10.0.33.0/24"
]
web_private_subnet_cidrs = [
  "10.0.34.0/24",
  "10.0.35.0/24",
  "10.0.36.0/24"
]
db_private_subnet_cidrs = [
  "10.0.37.0/24",
  "10.0.38.0/24",
  "10.0.39.0/24"
]

# EC2
ec2_ami      = "ami-004961349a19d7a8f"
ec2_type     = "t2.small"
ec2_user_data_script_path = "./user_data.sh"
ec2_working_dir = "/home/ec2-user/server"

# RDS
rds_instance_class = "db.t3.micro"
rds_allocated_storage = 20
rds_engine = "postgres"
rds_engine_version = "16.1"
rds_username = "test"
rds_password = "yourStrong(!)Password"

