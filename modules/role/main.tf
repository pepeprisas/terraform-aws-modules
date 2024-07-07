resource "aws_iam_role" "role" {
  name = "${var.account}-${terraform.workspace}-${var.service}-role-${var.freetext}"

  assume_role_policy = var.assumepolicy
  
  tags = {
    Name = "${var.account}-${terraform.workspace}-${var.service}-role-${var.freetext}"
    Account = var.account
    Resource = "role"
    Service = var.service
  }
}
resource "aws_iam_instance_profile" "profile" {
  name = "${var.account}-${terraform.workspace}-${var.service}-profile-${var.freetext}"
  role = aws_iam_role.role.name
}
resource "aws_iam_role_policy" "policy" {
  depends_on = [aws_iam_role.role]
  name = "${var.account}-${terraform.workspace}-${var.service}-policy-${var.freetext}"
  role = aws_iam_role.role.id
  policy = var.policy

}

output "profilename"{
  value=aws_iam_instance_profile.profile.name
  }