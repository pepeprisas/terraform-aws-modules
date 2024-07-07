resource "aws_route53_zone" "private_hosted_zone" {
  name = "${var.domain}"

  vpc {
    vpc_id = "${var.vpc_id}"
  }

  tags = {
    Name = "${var.service}-${var.role}-${var.domain}-${var.environment}"
    Service = "${var.service}"
    Role = "${var.role}"
    Environment ="${var.environment}"
    Region ="${var.region}"
  }
}
