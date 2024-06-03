########################
#         AWS          #
########################
variable "aws_region" {
  description = "aws region"
  type        = string
  default     = "eu-west-2"
}

########################
#   Resource Naming    #
########################
variable "name" {
  description = "name"
  type        = string
  default     = "ha-ec2-bp"
}

########################
#        tags          #
########################
variable "project" {
  description = "The name of the project"
  type        = string
  default     = "ha-ec2-tf-blueprint"
}

variable "client" {
  description = "The client for the project"
  type        = string
  default     = "public"
}

variable "owner" {
  description = "The owner of the project"
  type        = string
  default     = "Klyde-Moradeyo"
}

variable "namespace" {
  description = "Logical grouping for resources, such as by service"
  type        = string
  default     = "terraform-template"
}

variable "environment" {
  description = "The project environment"
  type        = string
  default     = "dev"
}

########################
#          EC2         #
########################
variable "ec2_arm_ami" {
  description = "EC2 ARM AMI"
  type        = string
}

variable "ec2_intel_ami" {
  description = "EC2 ARM AMI"
  type        = string
}

variable "ec2_type" {
  description = "EC2 Instance Type"
  type        = string
}

variable "ec2_user_data_script_path" {
  type        = string
  description = "Path to the user data script"
}

variable "ec2_working_dir" {
  type        = string
  description = "The working directory on the EC2 instance"
}


##########################
#          RDS           #
##########################
variable "rds_instance_class" {
  description = "The instance type of the RDS instance"
  type        = string
}

variable "rds_allocated_storage" {
  description = "The allocated storage in gibibytes"
  type        = number
}

variable "rds_engine" {
  description = "The database engine to use"
  type        = string
}

variable "rds_engine_version" {
  description = "The engine version to use"
  type        = string
}

variable "rds_username" {
  description = "Username for the RDS database"
  type        = string
}

variable "rds_password" {
  description = "Password for the RDS database"
  type        = string
  sensitive   = true
}

########################
#   Security Groups    #
########################
variable "allowed_cidrs" {
  description = "Allow these CIDR blocks to the server - default is the Universe"
  type        = string
  default     = "0.0.0.0/0" // https://cidr.xyz/
}

########################
#        VPC           #
########################
variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

########################
#        Subnet        #
########################
variable "public_subnet_cidrs" {
  description = "The CIDR block for the public Subnet."
  type        = list(string)
}

variable "web_private_subnet_cidrs" {
  description = "The CIDR block for the web server private Subnet."
  type        = list(string)
}

variable "db_private_subnet_cidrs" {
  description = "The CIDR block for the database private Subnet."
  type        = list(string)
}

