################
# stack/vpc.tf #
################

#VPC Configuration
module "vpc" {
  source = "git::https://github.com/TechHoldingLLC/terraform-aws-vpc?ref=v1.0.3"

  name = var.prefix
  cidr_block = lookup(
    {
      dev  = "10.0.0.0/16",
      prod = "10.3.0.0/16"
    },
    var.env
  )

  nat_type               = "gateway"
  create_private_subnets = true
  number_of_aws_az_use   = 2

  providers = {
    aws = aws
  }
}
