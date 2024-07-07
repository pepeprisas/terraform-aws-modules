output "arn" {
  value = aws_instance.instance.arn
}

output "instance_id" {
  value = aws_instance.instance.id
}

output "public_ip" {
  value = aws_instance.instance.public_ip
}
output "privateip" {
  value = aws_instance.instance.private_ip
}

output "subnet" {
  value = aws_instance.instance.subnet_id
} 
output "sgid" {
  value = aws_security_group.ec2-sg.*.id
}