###############################
# stack/ecs-farget-cluster.tf #
###############################

module "ecs_fargate_cluster" {
  source = "git::https://github.com/TechHoldingLLC/terraform-aws-ecs-cluster.git?ref=v1.0.0"

  name = var.prefix

  container_insights = "enabled"

  capacity_providers = ["FARGATE"]
  default_capacity_provider_strategy = {
    "FARGATE" = {
      base   = 1
      weight = 100
    }
  }

  providers = {
    aws = aws
  }
}
