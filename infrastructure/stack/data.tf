#################
# stack/data.tf #
#################

#IAM policy for GitHub Action 
data "aws_iam_policy" "github_oidc_policy" {
  name = "AdministratorAccess"
}

#----------------------------------------------------------------------------
#  Locals
#----------------------------------------------------------------------------
locals {
  th_ind_office_ips = ["106.201.230.83/32", "14.194.211.106/32"]

  domain = lookup(local.domain_config, var.env)

  #Change domain config & vpc domain to your preferred domain name
  domain_config = {
    dev  = "dev.lookingglasslifestyle.com"
    prod = "lookingglasslifestyle.com"
  }

  # This domain is used for backend
  api_domain = "api.${local.domain}"

}
