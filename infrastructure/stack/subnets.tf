####################
# stack/subnets.tf #
####################

#----------------------------------------------------------------------------
#  Locals
#----------------------------------------------------------------------------
locals {
  _network              = split(".", module.vpc.cidr_block)
  subnet_network_prefix = format("%s.%s", local._network[0], local._network[1])
}

#------------------------------------------------------------------------------------
# SUBNET ALB
#------------------------------------------------------------------------------------
module "subnet_alb" {
  source = "git::https://github.com/TechHoldingLLC/terraform-aws-subnet.git?ref=v1.0.1"

  name               = "${var.prefix}-alb"
  vpc_id             = module.vpc.id
  availability_zones = module.vpc.availability_zones

  # Public subnets
  public_route_table_ids = module.vpc.public_route_table_ids
  public_subnets = [
    {
      network = local.subnet_network_prefix
      cidr_blocks = [
        "10.0/24",
        "11.0/24"
      ]
    }
  ]

  providers = {
    aws = aws
  }
}

#------------------------------------------------------------------------------------
# SUBNET BASTION
#------------------------------------------------------------------------------------
module "subnet_bastion" {
  source = "git::https://github.com/TechHoldingLLC/terraform-aws-subnet.git?ref=v1.0.1"

  name               = "${var.prefix}-bastion"
  vpc_id             = module.vpc.id
  availability_zones = module.vpc.availability_zones

  # Public subnets
  public_route_table_ids = module.vpc.public_route_table_ids
  public_subnets = [
    {
      network = local.subnet_network_prefix
      cidr_blocks = [
        "12.0/24",
        "13.0/24"
      ]
    }
  ]

  providers = {
    aws = aws
  }
}

#------------------------------------------------------------------------------------
# SUBNET ECS
#------------------------------------------------------------------------------------
module "subnet_ecs" {
  source = "git::https://github.com/TechHoldingLLC/terraform-aws-subnet.git?ref=v1.0.1"

  name               = "${var.prefix}-ecs"
  vpc_id             = module.vpc.id
  availability_zones = module.vpc.availability_zones

  # Private subnets
  private_route_table_ids = module.vpc.private_route_table_ids
  private_subnets = [
    {
      network = local.subnet_network_prefix
      cidr_blocks = [
        "110.0/24",
        "111.0/24"
      ]
    }
  ]

  providers = {
    aws = aws
  }
}

#------------------------------------------------------------------------------------
# SUBNET DB
#------------------------------------------------------------------------------------
module "subnet_db" {
  source = "git::https://github.com/TechHoldingLLC/terraform-aws-subnet.git?ref=v1.0.1"

  name               = "${var.prefix}-db"
  vpc_id             = module.vpc.id
  availability_zones = module.vpc.availability_zones

  # Private subnets
  private_route_table_ids = module.vpc.private_route_table_ids
  private_subnets = [
    {
      network = local.subnet_network_prefix
      cidr_blocks = [
        "112.0/24",
        "113.0/24"
      ]
    }
  ]

  providers = {
    aws = aws
  }
}
