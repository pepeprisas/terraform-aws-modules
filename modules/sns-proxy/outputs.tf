output "lambda_arn" {
  value = "${aws_lambda_function.sns_proxy_lambda.arn}"
}