########################
#    Resource Naming   #
########################
variable "name" {
  description = "The name of the resources"
  type        = string
}

##########################
#        Network         #
##########################
variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "security_group_ids" {
  description = "ID for the security group"
  type        = list(string)
}

########################
#   EC2 Configuration  #
########################
variable "ami" {
  description = "AMI for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "Type of the EC2 instance"
  type        = string
}

variable "user_data" {
  description = "User data for EC2 instance"
  type        = string
  default     = null
}

variable "iam_instance_profile" {
  description = "EC2 Iam instance profile"
  type        = string
  default     = null
}

variable "key_name" {
  description = "The key name of the Key Pair to use for the instance - if not specified, EC2 Key Pair is not used"
  type        = string
  default     = null
}

variable "detailed_monitoring" {
  description = "Whether to enable detailed monitoring for EC2 instances."
  type        = bool
  default     = false
}

########################
#   ASG Configuration  #
########################
variable "min_size" {
  description = "Minimum size of the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum size of the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "desired_capacity" {
  description = "Desired capacity of the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "vpc_zone_identifiers" {
  description = "Subnets for the Auto Scaling Group"
  type        = list(string)
}

variable "target_group_arns" {
  description = "Target group ARNs for the Auto Scaling Group"
  type        = list(string)
  default     = []
}

########################
#         Tags         #
########################
variable "tags" {
  description = "Tags to assign"
  type        = map(string)
}