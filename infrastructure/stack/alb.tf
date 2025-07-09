################
# stack/alb.tf #
################

module "alb" {
  source = "git::https://github.com/TechHoldingLLC/terraform-aws-alb.git?ref=v1.0.4"

  create_alb      = true
  name            = var.prefix
  vpc_id          = module.vpc.id
  security_groups = [module.security_group_alb.id]
  subnets         = module.subnet_alb.public_subnet_ids

  create_alb_listener = true
  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"
      fixed_response = {
        content_type = "text/plain"
        message_body = "Bad request"
        status_code  = 400
      }
    }
    https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = module.acm.arn
      fixed_response = {
        content_type = "text/plain"
        message_body = "Bad request"
        status_code  = 400
      }
    }
  }

  enable_deletion_protection = true

  providers = {
    aws = aws
  }
}

# Security Group for ALB
module "security_group_alb" {
  source = "git::https://github.com/TechHoldingLLC/terraform-aws-security-group.git?ref=v1.0.0"

  name   = "${var.prefix}-alb"
  vpc_id = module.vpc.id
  ingress = [
    {
      port        = 80
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      port        = 443
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  providers = {
    aws = aws
  }
}
