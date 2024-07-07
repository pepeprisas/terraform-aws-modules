resource "aws_secretsmanager_secret" "ephemeralsecretmanager" {
  name = "${var.account}/${terraform.workspace}/${var.service}/${var.freetext}"
  tags = {
    Name        = "${var.account}-${terraform.workspace}-${var.service}-secretManager-${var.freetext}"
    Account     = var.account
    Resource    = "secretManager"
    Environment = terraform.workspace
    Service = var.service
  }
}

resource "aws_secretsmanager_secret_version" "secretstring" {
  secret_id      = aws_secretsmanager_secret.ephemeralsecretmanager.id
  secret_string  = jsonencode(var.secretmap)
}

output "secretid" {
  value = aws_secretsmanager_secret.ephemeralsecretmanager.id
}
