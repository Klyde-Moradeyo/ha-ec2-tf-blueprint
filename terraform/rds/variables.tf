########################
#    Resource Naming   #
########################
variable "name" {
  description = "The name of the resources"
  type        = string
}

##########################
#          RDS           #
##########################
variable "instance_class" {
  description = "The instance type of the RDS instance"
}

variable "allocated_storage" {
  description = "The allocated storage in gibibytes"
}

variable "engine" {
  description = "The database engine to use"
}

variable "engine_version" {
  description = "The engine version to use"
}

variable "username" {
  description = "Username for the RDS database"
}

variable "password" {
  description = "Password for the RDS database"
  sensitive   = true
}

variable "subnet_ids" {
  description = "A list of VPC subnet IDs"
}

variable "vpc_security_group_ids" {
  description = "A list of VPC security group IDs"
  default = []
}

variable "multi_az" {
  description = "If the RDS instance is multi-AZ"
  default     = false
}

variable "storage_encrypted" {
  description = "Specifies whether the DB instance is encrypted"
  default     = true
}

variable "backup_retention_period" {
  description = "The days to retain backups for"
  default     = 7
}

variable "db_parameters" {
  description = "A map of DB parameters to set in the parameter group. If not empty, a new parameter group is created."
  type        = map(string)
  default     = {}
}

########################
#         Tags         #
########################
variable "tags" {
  description = "Tags to assign"
  type        = map(string)
}