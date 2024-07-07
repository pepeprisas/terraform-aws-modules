resource "aws_security_group" "securitygroup" {
  name                   = "${var.country}-${var.team}-${terraform.workspace}-${var.service}-sg-${var.freetext}"
  description            = var.description
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = var.revoke_rules_on_delete

  tags = {
    Name        = "${var.country}-${var.team}-${terraform.workspace}-${var.service}-sg-${var.freetext}"
    Country     = var.country
    Team        = var.team
    Environment = terraform.workspace
    Resource    = var.resource
    Service     = var.service
    Autoremove  = var.autoremove
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_security_group_rule" "ingress_with_cidr_blocks" {
  count             = length(var.ingress_with_cidr_blocks)
  security_group_id = aws_security_group.securitygroup.id
  type              = "ingress"
  description       = var.ingress_with_cidr_blocks[count.index].description
  from_port         = var.ingress_with_cidr_blocks[count.index].from_port
  to_port           = var.ingress_with_cidr_blocks[count.index].to_port
  protocol          = var.ingress_with_cidr_blocks[count.index].protocol
  cidr_blocks       = [var.ingress_with_cidr_blocks[count.index].cidr_block]
}


resource "aws_security_group_rule" "egress_with_cidr_blocks" {
  count             = length(var.egress_with_cidr_blocks)
  security_group_id = aws_security_group.securitygroup.id
  type              = "egress"
  description       = var.egress_with_cidr_blocks[count.index].description
  from_port         = var.egress_with_cidr_blocks[count.index].from_port
  to_port           = var.egress_with_cidr_blocks[count.index].to_port
  protocol          = var.egress_with_cidr_blocks[count.index].protocol
  cidr_blocks       = [var.egress_with_cidr_blocks[count.index].cidr_block]
}