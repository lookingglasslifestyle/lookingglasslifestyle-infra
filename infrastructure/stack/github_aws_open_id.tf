###############################
# stack/github_aws_open_id.tf #
###############################

#------------------------------------------------------------------------------------
# GitHub AWS OpenID connect using Identity Provider
#------------------------------------------------------------------------------------
module "github_aws_open_id" {
  source = "git::https://github.com/TechHoldingLLC/terraform-aws-github-oidc.git?ref=v1.0.3"

  role_name = "${var.prefix}-github-actions"

  env_repo_config = {
    "${var.env}" = local.github_repos
  }
  providers = {
    aws = aws
  }
}

resource "aws_iam_role_policy_attachment" "github_oidc_policy" {
  role       = module.github_aws_open_id.iam_role_name
  policy_arn = data.aws_iam_policy.github_oidc_policy.arn
}

locals {
  github_repos = [
    "lookingglasslifestyle/lookingglasslifestyle-infra"
  ]
}
