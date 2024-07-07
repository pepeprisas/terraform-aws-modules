## AWS DynamoDB table for Terraform locking

State locking and consistency checking via Dynamo DB. A single DynamoDB table can be used to lock multiple remote state files:  
https://www.terraform.io/docs/backends/types/s3.html

### Ussage
Just add to your `main.tf` file:  
```
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "uk-devops-production-dynamodb-terraform-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}
```
