variable "region" {
  default = "eu-west-1"
}
variable "team" {
  default = "devops"
}
variable "service" {
  default = "backup"
}
variable "function_name" {
  default = "function"
}
variable "resource" {
  default = "s3"
}
variable "country" {
  default = "uk"
}
variable "environment" {
  description = "Environment"
  type = map
  default = {
    "staging" = "staging"
    "production" = "production"
  }
}
variable "resources_to_backup" {
  description = "List of arn resources to backup"
  type        = map
  default     = {
    staging = [
    ]
    production = [ 
      {
        arn  = "arn:aws:ec2:eu-west-1:XXXXXXXXXXXXX:instance/i-XXXXXXXXXXXXX", 
        name = "XXXXXXXXXXXXX",
      },
      {
        arn  = "arn:aws:ec2:eu-west-1:XXXXXXXXXXXXX:instance/i-XXXXXXXXXXXXX", 
        name = "XXXXXXXXXXXXX",
      },      
      {
        arn  = "arn:aws:dynamodb:eu-west-1:XXXXXXXXXXXXX:table/xXXXXXXXXXXXXX-terraform-lock", 
        name = "XXXXXXXXXXXXX",
      },
    ]
  }
}
variable "delete_after" {
  description = "Days after backup is deleted"
  type        = map
  default     = {
    staging    = 97
    production = 97
  }
}  
variable "cold_storage_after" {
  description = "Transition to Cold Storage"
  type        = map
  default     = {
    staging    = 7
    production = 7
  }
}  
variable "replica_region" {
  default = "eu-central-1"
}
variable "versioning" {
  default = true
}
variable "s3_to_backup" {
  description = "List of s3 resources to backup"
  type        = map
  default     = {
    staging = [
    ]
    production = [
	  "XXXXXXXXXXXXX",
    "XXXXXXXXXXXXX",
    "XXXXXXXXXXXXX",
    "XXXXXXXXXXXXX",
    ]
  }
}
variable "email_address" {
  default = "cloudarchitectureandsecurity@example.com"
}