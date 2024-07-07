output "sgid" {
  value = aws_security_group.sg.id
}
output "masterid" {
  value = "${data.aws_instance.master.id}"
}