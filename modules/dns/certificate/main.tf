resource "aws_acm_certificate" "cert" {
  count = "${length(keys(var.domains))}"
  domain_name       = "${var.domains[count.index]}"
  validation_method = "DNS"

  tags = {
    Name = "${var.service}-${var.role}-${var.domains[count.index]}-${var.environments[count.index]}"
    Service = "${var.service}"
    Role = "${var.role}"
    Environment ="${var.environments[count.index]}"
    Region ="${var.region}"
  }

  lifecycle {
    create_before_destroy = true
  }
}
