provider "aws" {
  region  = var.region
}

terraform {
  backend "s3" {
    bucket  = "main-eu-west-1-terraform-state-bucket"
    key     = "devops/main-eu-west-1-terraform-locks.tfstate"
    region  = "eu-west-1"
    encrypt = "true"
    acl     = "bucket-owner-full-control"
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "${var.country}-${var.team}-${terraform.workspace}-${var.service}-dynamodb"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = var.hash
  attribute {
    name = var.hash
    type = "S"
  }
  tags = {
    Environment = terraform.workspace
    Name  = "${var.country}-${var.team}-${terraform.workspace}-${var.service}-dynamodb"
    Country = var.country
    Resource = "tg"
    Environment = terraform.workspace
    Team = var.team
    Service = var.service
  }
}
