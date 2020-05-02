resource "aws_acm_certificate" "tls" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_lb" "this" {
  name               = "eks-${var.cluster_name}-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = module.vpc.public_subnets
  security_groups    = [aws_security_group.alb.id]
}
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
  certificate_arn   = aws_acm_certificate.tls.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}
resource "aws_lb_target_group" "this" {
  name     = "eks-${var.cluster_name}-target-group"
  port     = 30080
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
  health_check {
    path    = "/healthz" # for nginx ingress controller
    port    = 30254
    matcher = "200"
  }
}

# Security group for ALB
resource "aws_security_group" "alb" {
  name        = "eks-${var.cluster_name}-alb-sg"
  description = "ALB SG for eks ${var.cluster_name}"
  vpc_id      = module.vpc.vpc_id
  tags = {
    Name = "eks-${var.cluster_name}-alb-sg"
  }
}
locals {
  rules = {
    https = [
      "ingress",
      "tcp",
      443,
      aws_security_group.alb.id,
      null,
      [module.vpc.vpc_cidr_block],
      "HTTPS"
    ]
    http = [
      "ingress",
      "tcp",
      80,
      aws_security_group.alb.id,
      null,
      [module.vpc.vpc_cidr_block],
      "HTTP"
    ]
    out = [
      "egress",
      "tcp",
      30080,
      aws_security_group.alb.id,
      module.eks.worker_security_group_id,
      null,
      "Allow ALB to communicate with workers"
    ]
    in = [
      "ingress",
      "tcp",
      30080,
      module.eks.worker_security_group_id,
      aws_security_group.alb.id,
      null,
      "Allow ALB to communicate with workers"
    ]
    health-checks = [
      "ingress",
      "tcp",
      30254,
      module.eks.worker_security_group_id,
      aws_security_group.alb.id,
      null,
      "Healthcheck from ALB"
    ]
  }
}
resource "aws_security_group_rule" "this" {
  for_each                 = local.rules
  type                     = each.value[0]
  protocol                 = each.value[1]
  from_port                = each.value[2]
  to_port                  = each.value[2]
  security_group_id        = each.value[3]
  source_security_group_id = each.value[4]
  cidr_blocks              = each.value[5]
  description              = each.value[6]
}
