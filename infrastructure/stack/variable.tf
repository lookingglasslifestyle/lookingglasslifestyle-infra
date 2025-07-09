#######################
#  stack/variable.tf  #
#######################

variable "env" {
  description = "Deployment environment"
}

variable "prefix" {
  description = "Resource name prefix"
}

variable "aws_region" {
  description = "AWS region"
}

variable "aws_profile" {
  description = "AWS Profile"
}

variable "ssm_prefix" {
  description = "SSM Prefix"
}

variable "repo_name" {
  description = "Repository Name"
  type        = string
}

# ------------------------------------------------------------------------------
# RDS POSTGRESQL
# ------------------------------------------------------------------------------

variable "db_username" {
  description = "Master username for RDS aurora-postgresql"
  type        = string
}

variable "db_password" {
  description = "Master password for RDS aurora-postgresql"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}