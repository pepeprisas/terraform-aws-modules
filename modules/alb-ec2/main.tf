data "aws_subnet" "selected" {
  id = var.subnet_id[0]
}
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_lb" "ec2_alb" {
  name               = "${var.account}-${terraform.workspace}-${var.service}-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = var.sgid
  subnets            = var.subnet_id

  enable_deletion_protection = false


  tags = {
    Name        = "${var.account}-${terraform.workspace}-${var.service}-alb"
    Resource    = "alb"
    Environment = terraform.workspace
    Service = var.service
  }
}
resource "aws_lb_target_group" "ec2_target" {
  vpc_id = data.aws_subnet.selected.vpc_id
  name   = "${var.account}-${terraform.workspace}-${var.service}-tg"
  port     = var.port
  protocol = "HTTP"
  tags = {
    Name        = "${var.account}-${terraform.workspace}-${var.service}-tg"
    Resource    = "tg"
    Environment = terraform.workspace
    Service = var.service
  }
}

module "certificates" {
  source = "git::ssh://git@github.com/${var.githubproject}.git//mappings/certificates"
}
resource "aws_lb_listener" "ec2_listener" {
  load_balancer_arn = aws_lb.ec2_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn = module.certificates.corporate_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ec2_target.arn
  }
}
resource "aws_lb_listener" "ec2_listener80" {
  load_balancer_arn = aws_lb.ec2_alb.arn
  port              = "80"
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
resource "aws_lb_target_group_attachment" "ec2preditattach" {
  target_group_arn = aws_lb_target_group.ec2_target.arn
  target_id        = var.ec2id
  port             = var.port
}
