##################
#  stack/rds.tf  #
##################

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.prefix}-rds-subnet-group"
  subnet_ids = module.subnet_db.private_subnet_ids
}

#Security Group for RDS Postgresql
module "security_group_rds_postgresql" {
  source = "git::https://github.com/TechHoldingLLC/terraform-aws-security-group.git?ref=v1.0.0"

  name   = "${var.prefix}-rds-postgresql"
  vpc_id = module.vpc.id
  ingress = [
    {
      port                     = 5432
      source_security_group_id = module.security_group_bastion.id
      description              = "Security Group of Bastion"
    }
  ]

  providers = {
    aws = aws
  }
}

resource "aws_db_instance" "postgresql" {
  identifier             = "${var.prefix}-rds-postgresql"
  engine                 = "postgres"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  username               = var.db_username
  password               = var.db_password
  port                   = 5432
  publicly_accessible    = false
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [module.security_group_rds_postgresql.id]
  skip_final_snapshot    = false
  deletion_protection    = true
  storage_encrypted = true
  parameter_group_name = aws_db_parameter_group.postgresql_parameter_group.name
}

# Optional: Create a custom parameter group for PostgreSQL
resource "aws_db_parameter_group" "postgresql_parameter_group" {
  name        = "${var.prefix}-parameter-group"
  family      = "postgres15"  # Choose based on your engine/version
  description = "Custom parameter group for PostgreSQL 15"
}