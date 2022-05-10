locals {
  bastion_name = "example-bastion"
}

resource "aws_security_group" "bastion" {
  name        = "${var.namespace}-${local.bastion_name}"
  description = "Security group that only allows egress"
  tags        = var.tags
  vpc_id      = module.vpc.vpc_id
}

# The bastion needs outbound 443 to talk to the AWS Session Manager API
resource "aws_security_group_rule" "https" {
  security_group_id = aws_security_group.bastion.id
  type              = "egress"
  protocol          = "tcp"
  to_port           = 443
  from_port         = 443
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

# Allow the bastion outbound to the ports where users will be tunneling to
resource "aws_security_group_rule" "tunnel" {
  security_group_id = aws_security_group.bastion.id
  type              = "egress"
  protocol          = "tcp"
  to_port           = module.db.cluster_port
  from_port         = module.db.cluster_port
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

module "ec2_bastion_server" {
  source  = "cloudposse/ec2-bastion-server/aws"
  version = "0.30.0"

  ami_filter             = { "name" : ["amzn2-ami-hvm-*-x86_64-gp2"] }
  ami_owners             = ["amazon"]
  assign_eip_address     = false
  instance_type          = "t2.micro"
  name                   = local.bastion_name
  namespace              = var.namespace
  security_group_enabled = false
  security_groups        = [aws_security_group.bastion.id]
  ssm_enabled            = true
  subnets                = module.dynamic_subnets.private_subnet_ids
  tags                   = var.tags
  vpc_id                 = module.vpc.vpc_id
}
