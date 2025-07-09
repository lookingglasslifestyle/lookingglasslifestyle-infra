######################
#  stack/outputs.tf  #
######################

# Output for Bastion Host Public IP
output "bastion_public_ip" {
  value     = module.ec2_bastion.public_ip
  sensitive = true
}

# Output for Bastion Host Instance ID
output "bastion_instance_id" {
  value     = module.ec2_bastion.instance_id
  sensitive = true
}

# Output for RDS Aurora PostgreSQL credentials
output "db_creds" {
  value = jsonencode({
    endpoint           = aws_db_instance.postgresql.endpoint,
    master_username    = aws_db_instance.postgresql.username,
    master_password    = aws_db_instance.postgresql.password,
    db_name            = aws_db_instance.postgresql.db_name,
    cluster_identifier = aws_db_instance.postgresql.identifier,
  })
  sensitive = true
}