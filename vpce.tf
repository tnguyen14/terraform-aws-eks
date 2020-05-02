variable "vpce_services" {
  type    = list
  default = ["ssm", "ec2messages", "ssmmessages"]
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls_from_vpc"
  description = "Allow TLS inbound traffic from VPC"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  tags = map(
    "Name", "vpce-interface-sg"
  )
}

resource "aws_vpc_endpoint" "endpoint" {
  for_each            = toset(var.vpce_services)
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.${each.key}"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids         = [module.vpc.private_subnets.0]
  security_group_ids = [aws_security_group.allow_tls.id]

  tags = map(
    "EndpointService", each.key
  )
}
