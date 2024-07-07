resource "aws_route53_zone" "public_hosted_zone" {
  count = "${length(keys(var.domains))}"
  name = "${var.domains[count.index]}"

  tags = {
    Name = "${var.service}-${var.role}-${var.domains[count.index]}-${var.environments[count.index]}"
    Service = "${var.service}"
    Role = "${var.role}"
    Environment ="${var.environments[count.index]}"
    Region ="${var.region}"
  }
}
