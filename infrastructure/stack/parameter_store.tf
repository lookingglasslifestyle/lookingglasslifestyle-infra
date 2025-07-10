############################
# stack/parameter-store.tf #
############################

#SSM paramater
module "ssm_params" {
  source = "git::https://github.com/TechHoldingLLC/terraform-aws-parameter-store.git?ref=v0.0.1"

  ##  prefix the prifix name should be project_name/environment
  prefix = var.ssm_prefix
  ## module_name should be the the name of module and name of component e.g. vpc/vpc_name
  parameters = {
    "vpc/default" = {
      vpc_id = module.vpc.id,
    },

    "ecs/default" = {
      cluster_arn  = module.ecs_fargate_cluster.arn,
      cluster_name = module.ecs_fargate_cluster.name
    },

    "subnet/ecs" = {
      id          = jsonencode(module.subnet_ecs.private_subnet_ids)
      cidr_blocks = jsonencode(module.subnet_ecs.private_subnet_cidr_blocks)
    },

    "subnet/db" = {
      id = jsonencode(module.subnet_db.private_subnet_ids)
    },

    "route53/default" = {
      zone_id = aws_route53_zone.hosted-zone.zone_id
    },

    "rds/default" = {
      db_username       = aws_db_instance.postgresql.username,
      db_password       = aws_db_instance.postgresql.password,
      endpoint          = split(":", aws_db_instance.postgresql.endpoint)[0],
      port              = aws_db_instance.postgresql.port,
      security_group_id = module.security_group_rds_postgresql.id
    },

    "alb/default" = {
      arn                = module.alb.arn,
      dns_name           = module.alb.dns,
      zone_id            = module.alb.zone_id,
      http_listener_arn  = module.alb.listeners.http.arn,
      https_listener_arn = module.alb.listeners.https.arn,
      security_group_id  = module.security_group_alb.id
    },

    "acm/default" = {
      arn = module.acm.arn,
    },

    "ec2/bastion" = {
      public_ip         = module.ec2_bastion.public_ip,
      security_group_id = module.security_group_bastion.id,
    }
  }

  providers = {
    aws = aws
  }
}
