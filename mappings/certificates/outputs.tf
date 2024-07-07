output "corporate_arn" {
  value = "arn:aws:acm:eu-west-1:123456789012:certificate/12c456b8-12c4-56b8-012c-12c456b89012"
}

output "certificates" {
  value = "${var.certificates}"
}
