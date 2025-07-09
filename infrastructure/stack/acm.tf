################
# stack/acm.tf #
################

# This ACM certificate is used for Application Load Balancer (ALB) and CloudFront
module "acm" {
  source = "git::https://github.com/TechHoldingLLC/terraform-aws-acm.git?ref=v1.1.1"

  domain_config = [
    {
      hosted_zone_id = aws_route53_zone.hosted-zone.zone_id,
      domain_name    = ["${local.domain}", "*.${local.domain}"]
    }
  ]

  providers = {
    aws = aws
  }
}
