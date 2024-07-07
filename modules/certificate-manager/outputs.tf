output "aws_acm_certificate_arn_id" {
  value = aws_acm_certificate.certificate.id
  description = "The certificate arn id"
}
