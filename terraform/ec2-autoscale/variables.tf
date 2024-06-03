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
variable "default_instance_type" {
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
  default     = 3
}

variable "desired_capacity" {
  description = "Desired capacity of the Auto Scaling Group"
  type        = number
  default     = 2
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

########################
#    Spot Instances    #
########################
variable "spot_configuration" {
  description = "Configuration options for Spot Instances within the Auto Scaling Group. Determines if Spot Instances are enabled and details their configuration."
  type = object({
    enabled                       = bool 
    max_price                     = number  
    on_demand_base_capacity       = optional(number)  
    on_demand_percentage_above_base_capacity = optional(number)
    allocation_strategy           = optional(string)      
    instance_pools                = optional(number)   
  })
  default = {
    enabled                       = false
    max_price                     = null
    on_demand_base_capacity       = 0
    on_demand_percentage_above_base_capacity = 100
    allocation_strategy           = "lowest-price"
    instance_pools                = 2
  }
}

variable "instance_types_config" {
  description = "Map of instance types to their AMI and weighted capacities"
  type = map(object({
    ami              = string
    weighted_capacity = number
  }))
  default = {}
}

variable "instance_type_overrides" {
  description = "List of additional instance types that the ASG can launch. Useful for diversifying the instances to optimize cost and availability."
  type        = list(string)
  default     = []
}
