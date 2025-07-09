################
# stack/ec2.tf #
################

data "aws_ami" "amazon_linux_bastion" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"] # Canonical
}

module "ec2_bastion" {
  source = "git::https://github.com/TechHoldingLLC/terraform-aws-ec2.git?ref=v1.0.1"

  name          = "${var.prefix}-bastion"
  ami_id        = data.aws_ami.amazon_linux_bastion.id #ami_id changes are ignored at a module level
  instance_type = "t3.nano"
  key_name      = "${var.prefix}-${var.aws_region}"

  enable_volume_tags = true

  # Network
  vpc_id = module.vpc.id
  subnet = element(module.subnet_bastion.public_subnet_ids, 0)
  eip    = true

  #Security Group
  security_group_ids = [module.security_group_bastion.id]

  providers = {
    aws = aws
  }
}

#Security Group for Bastion
module "security_group_bastion" {
  source = "git::https://github.com/TechHoldingLLC/terraform-aws-security-group.git?ref=v1.0.0"

  name   = "${var.prefix}-bastion-ec2"
  vpc_id = module.vpc.id
  egress = [
    {
      protocol    = -1
      port        = 0
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  ingress = [
    {
      port        = 22
      cidr_blocks = local.th_ind_office_ips
      description = "SSH: TH Ahmedabad Office IPs"
    }
  ]

  providers = {
    aws = aws
  }
}
