## AWS Terraform module for Lambda function with Docker

Deploying [Lambda](https://docs.aws.amazon.com/lambda/latest/dg/welcome.html) with [Terraform](https://www.terraform.io/) version >= 0.12 with [Docker](https://aws.amazon.com/blogs/aws/new-for-aws-lambda-container-image-support/)


## Configuration
To create a new project sourcing from this module you have to specify in your project `main.tf` file the following data:  
```
provider "aws" {
  region        = "eu-west-1"
}

module "lambda_function" {
  source       = "git::ssh://git@github.com/${var.githubproject}.git//modules/lambda-docker"
  resource     = var.resource 
  country      = var.country
  team         = var.team
  environment = terraform.workspace
  resource    = var.resource
  image       = var.image
}
```

In the `varables.tf` define the variables that you will pass to this module like:
```
variable "region" {
  default = "eu-west-1"
}

variable "country" {
  default = "uk"
}

variable "team" {
  default = "devops"
}

variable "resource" {
  default = "lambda"
}

variable "image" {
  default = "access-keys-deletion"
}
```

This module by default creates the AssumedRole policy for Lambda service, as well as the required policy for CloudwatchLogs 

Any additional policies should be created and attached to the service role created by the module, in a similar way as follows (this example is for Access Keys rotation):
```
data "aws_iam_policy_document" "lambdaIAM" {

  statement {
    sid = "LambdaAccessKeysIAM"
    actions = [
      "iam:ListUsers",
      "iam:CreateAccessKey",
      "iam:DeleteAccessKey",
      "iam:GetAccessKeyLastUsed",
      "iam:GetUser",
      "iam:ListAccessKeys",
      "iam:UpdateAccessKey"
    ]

    resources = ["*"]
  }

}

resource "aws_iam_policy" "lambdaEC2Policy" {
  name = "${var.country}-${var.team}-${terraform.workspace}-${var.name}-ec2-policy"
  policy = data.aws_iam_policy_document.lambdaEC2.json
}

resource "aws_iam_role_policy_attachment" "attachment" {
  role       = module.lambda_function.role
  policy_arn = aws_iam_policy.lambdaEC2Policy.arn
}
```

## Dockerfile
Enable MFA AWS token localy in your console. This `lambda-docker-0.12` module pushes to AWS container registry, be sure you are logged with ECR doing one `aws ecr get-login` before you execute this makefile.

Create the Dockerfile accordingly to the `oficial` docker base [images](https://docs.aws.amazon.com/lambda/latest/dg/runtimes-images.html#runtimes-images-lp) for all the supported Lambda runtimes (Python, Node.js, Java, .NET, Go, Ruby)  because they need to have implemented the Lambda Runtime API.

This is an example that we will commonly use for Python 3.8:
```
FROM amazon/aws-lambda-python:3.8
RUN /var/lang/bin/python3.8 -m pip install --upgrade pip wheel
COPY requirements.txt ./
RUN pip install -r requirements.txt
COPY script/index.py ./
CMD [ "index.handler" ]
```

Place in `requirements.txt` file the python libraries needed for the lambda to run, like for example:
```
boto3
botocore
datetime
pyminizip
```

Test docker image locally. Keep in mind that if you are using `boto3` you should pass your local AWS credentials like this to test if before push everything to lambda (and that your user may not have sufficient permissions):
```
$ docker run --env AWS_PROFILE=devops -p 9000:8080 lambda/your-lambda-image:latest
```

Now, test the function invocation with a cURL passing an empty JSON payload:
```
$ curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{}'
```
