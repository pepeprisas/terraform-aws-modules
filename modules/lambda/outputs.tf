output "name" {
  value = aws_lambda_function.lambdaFunction.function_name
}

output "arn" {
  value = aws_lambda_function.lambdaFunction.arn
}

output "role" {
  value = aws_iam_role.lambdaRole.name
}
