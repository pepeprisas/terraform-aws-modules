resource "aws_efs_file_system" "efs" {
  creation_token = "${var.account}-${terraform.workspace}-${var.service}-efs"
  encrypted = "true"
  tags = {
    Name  = "${var.account}-${terraform.workspace}-${var.service}-efs"
    Account = var.account
    Resource = "ecsTaskDefinition"
    Backup = "${var.account}-${terraform.workspace}"
    Service = var.service
  }
 }

resource "aws_efs_mount_target" "efs" {
  file_system_id = aws_efs_file_system.efs.id
  subnet_id      = var.subnet_ids
  security_groups = var.efs_security_group
}