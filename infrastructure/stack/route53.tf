#####################
#  stack/rout53.tf  #
#####################

# Route53 Hosted Zone
resource "aws_route53_zone" "hosted-zone" {
  name = local.domain

  lifecycle {
    prevent_destroy = true
  }
}

##########
# Bastion Ip record
##########
resource "aws_route53_record" "bastion_ip" {
  zone_id = aws_route53_zone.hosted-zone.zone_id
  name    = "bastion.${local.domain}"
  type    = "A"
  ttl     = 300
  records = [module.ec2_bastion.public_ip]

  lifecycle {
    prevent_destroy = true
  }
}

##########
# Route53 record ALB
##########
resource "aws_route53_record" "alb_dns" {
  zone_id = aws_route53_zone.hosted-zone.id
  name    = local.api_domain
  type    = "A"

  alias {
    name                   = module.alb.dns
    zone_id                = module.alb.zone_id
    evaluate_target_health = true
  }
}
