output "arn" {
  value = aws_alb.alb.arn
}

output "target-group-arn" {
  value = aws_alb_target_group.alb-target-group.arn
}

output "alb-sg-id" {
  value = aws_security_group.alb-sg.id
}

output "connect-sg-id" {
  value = aws_security_group.connect-sg.id
}

output "dns-name" {
  value = aws_alb.alb.dns_name
}