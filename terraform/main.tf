########################
#        tags          #
########################
module "tags" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/tags/helpers"
  version = "0.0.1"

  project     = var.project
  client      = var.client
  namespace   = var.namespace
  owner       = var.owner
  environment = var.environment
}

data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}