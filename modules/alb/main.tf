

resource "aws_security_group" "connect-sg" {
  name = "${var.account}-${terraform.workspace}-${var.service}-albConnectSg"
  description = "Allows connections to main alb"
  vpc_id = var.vpc_id

  tags  = {
    Name  = "${var.account}-${terraform.workspace}-${var.service}-albConnectSg"
    Account = var.account
    Resource = "alb-connect-sg"
    Service = var.service
  }
}


resource "aws_security_group" "alb-sg" {
  name = "${var.account}-${terraform.workspace}-${var.service}-albSg"
  description = "ALB security group."
  vpc_id = var.vpc_id

  ingress {
    protocol = "tcp"
    from_port = 443
    to_port = 443
    cidr_blocks = var.cidr_blocks
    security_groups = [
      aws_security_group.connect-sg.id]
  }

  ingress {
    protocol = "tcp"
    from_port = 443
    to_port = 443
    security_groups = var.securitygroup_ids
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags  = {
    Environment = terraform.workspace
    Name  = "${var.account}-${terraform.workspace}-${var.service}-albSg"
    Account = var.account
    Resource = "alb-sg"
    Service = var.service
  }
}

resource "aws_alb" "alb" {
  name = "${var.account}-${terraform.workspace}-${var.service}-alb"
  subnets = var.subnet-id
  security_groups = [
    aws_security_group.alb-sg.id]
  internal = true

  access_logs {
    enabled = false
    bucket = ""
  }

  tags  = {
    Environment = terraform.workspace
    Name  = "${var.account}-${terraform.workspace}-${var.service}-alb"
    Account = var.account
    Resource = "alb"
    Service = var.service
  }
}

resource "aws_alb_target_group" "alb-target-group" {
  name = "${var.account}-${terraform.workspace}-${var.service}-Tg"
  port = var.healthcheck-port
  protocol = "HTTP"
  vpc_id = var.vpc_id
  target_type = "ip"
  lifecycle {
    create_before_destroy = true
  }

  health_check {
    path = var.healthcheck-route
    matcher = var.healthcheck-status-code
  }

  stickiness {
    type = "lb_cookie"
    cookie_duration = var.state-cookie-duration
    enabled = var.stateful
  }

  tags  = {
    Environment = terraform.workspace
    Name  = "${var.account}-${terraform.workspace}-${var.service}-albTg"
    Account = var.account
    Resource = "tg"
    Service = var.service
  }
}

resource "aws_alb_listener" "https-alb-listener" {
  load_balancer_arn = aws_alb.alb.arn
  port = "443"
  protocol = "HTTPS"

  certificate_arn = var.ssl-certificate-arn

  default_action {
    target_group_arn = aws_alb_target_group.alb-target-group.arn
    type = "forward"
  }
}

# Redirect from http to https
resource "aws_alb_listener" "http-alb-listener" {
  load_balancer_arn = aws_alb.alb.arn
  port = "80"
  protocol = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port = "443"
      protocol = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
