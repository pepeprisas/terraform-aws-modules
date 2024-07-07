## AWS Lambda Module deployment with terraform

Deploying [Lambda](https://docs.aws.amazon.com/lambda/latest/dg/welcome.html) with [Terraform](https://www.terraform.io/) version >= 0.12


## Configuration
To create a new project sourcing from this module you have to specify in your project `main.tf` file the following data:  
```
provider "aws" {
  region        = "eu-west-1"
}

module "lambda" {
  source       = "git::ssh://git@github.com/${var.githubproject}.git//modules/lambda"
  country = var.country
  team = var.team
  service = var.service 
  freetext = <free_text_of_choice> 
  function = <directory_under_scripts_folder_where_lambda_code_is_stored>
}
```


To create a Lambda with an specific VPC config, add the following lines:

```terraform
  vpcs = [{
    subnet_ids = ["subnet-0d7c1e2a286dfda66"],
    security_group_ids = ["sg-00770507cf90abdcd"]
  }]
```

In the `?ref=v1.0.1` version you should specify the latest stable version specified in CHANGELOG.md file from the Github repository.

it is very likely that you will have to modify this module to your needs. For example tyhe cronjob time and the Lambda `aws_iam_policy_document` data. Do *NOT* modify it in the Infrastructure repository. In that case copy this module to your directory, modify it there to your needs and call it in the following way:  
```
module "lambda" {
  source = "./lambda"
  country = var.country
  team = var.team
  service = var.service 
  freetext = <free_text_of_choice> 
  function = <directory_under_scripts_folder_where_lambda_code_is_stored>
}
```

After this, create in the `variables.tf` file in your project with the needed variables:  
```
variable "region" {
  default = "eu-west-1"
}

variable "country" {
  default = "..."
}

variable "team" {
  default = "..."
}

variable "service" {
  default = "...."
}
```
