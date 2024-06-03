########################
#        VPC           #
########################
module "vpc" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/vpc/aws"
  version = "0.0.1"

  name                 = var.name
  vpc_cidr             = var.vpc_cidr
  enable_dns_hostnames = true
  tags                 = module.tags.tags
}

########################
#        Subnets       #
########################
locals {
  public_subnets      = { for i, az in data.aws_availability_zones.available.names : az => element(var.public_subnet_cidrs, i) }
  web_private_subnets = { for i, az in data.aws_availability_zones.available.names : az => element(var.web_private_subnet_cidrs, i) }
  db_private_subnets  = { for i, az in data.aws_availability_zones.available.names : az => element(var.db_private_subnet_cidrs, i) }
}

module "web_private_subnets" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/subnet/aws"
  version = "0.0.1"

  name                    = "${var.name}-web-private"
  vpc_id                  = module.vpc.vpc_id
  subnets                 = local.web_private_subnets
  map_public_ip_on_launch = false

  tags = module.tags.tags
}

module "db_private_subnets" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/subnet/aws"
  version = "0.0.1"

  name                    = "${var.name}-db-private"
  vpc_id                  = module.vpc.vpc_id
  subnets                 = local.db_private_subnets
  map_public_ip_on_launch = false

  tags = module.tags.tags
}

module "public_subnets" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/subnet/aws"
  version = "0.0.1"

  name                    = "${var.name}-public"
  vpc_id                  = module.vpc.vpc_id
  subnets                 = local.public_subnets
  map_public_ip_on_launch = true

  tags = module.tags.tags
}

########################
#    Route Table       #
########################
module "public_route_table" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/route-table/aws"
  version = "0.0.1"

  name   = "${var.name}-public"
  vpc_id = module.vpc.vpc_id
  routes = [
    {
      cidr_block = "0.0.0.0/0"
      gateway_id = module.internet_gateway.internet_gateway_id
    }
  ]
  subnets = module.public_subnets.subnet_ids

  tags = module.tags.tags
}

module "private_route_table" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/route-table/aws"
  version = "0.0.1"

  count = length(module.web_private_subnets.subnet_ids)

  name   = "${var.name}-${count.index}-private"
  vpc_id = module.vpc.vpc_id
  routes = [{
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = module.nat_gateway[count.index].nat_gateway_id
  }]
  subnets = [module.web_private_subnets.subnet_ids[count.index]]

  tags = module.tags.tags
}

########################
#   Internet Gateway   #
########################
module "internet_gateway" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/internet-gateway/aws"
  version = "0.0.1"

  name   = var.name
  vpc_id = module.vpc.vpc_id

  tags = module.tags.tags
}

########################
#      NAT Gateway     #
########################
module "nat_gateway" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/nat-gateway/aws"
  version = "0.0.1"

  count = length(module.public_subnets.subnet_ids)

  name = "${var.name}-${count.index}"

  subnet_id = module.public_subnets.subnet_ids[count.index]

  tags = module.tags.tags
}

