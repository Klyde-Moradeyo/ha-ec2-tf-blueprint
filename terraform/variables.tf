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
variable "ec2_ami" {
  description = "EC2 AMI"
  type        = string
}

variable "ec2_type" {
  description = "EC2 Instance Type"
  type        = string
}

variable "ec2_userdata" {
  description = "EC2 User Data"
  type        = string
  default     = ""
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

variable "private_subnet_cidrs" {
  description = "The CIDR block for the private Subnet."
  type        = list(string)
}

