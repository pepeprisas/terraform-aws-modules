# albec2 Module
Create an alb for an ec2 instance

### Example

Include in your main.tf file:  
```
module "ec2" {
  source    = "git::ssh://git@github.com/${var.githubproject}.git//modules/alb-ec2"
  region    = var.region
  country   = var.country
  team      = var.team
  name      = var.freetext
  subnet_id = var.subnet_id
  sgid      = module.ec2.sgid
  ec2id     = module.ec2.instance_id
}
```

  
Pass the rest of the variables needed in your `variable.tf` file. For example:  
```
variable "region" {
}
variable "country" {
  description = "Country code https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes"
}
variable "team" {
  description = "devops|dev|data"
}
variable "name" {
  description = "freetext to explain the resource"
}
variable "subnet_id" {
  description = "Subnet in the vpc"
}
variable "sgid" {
  description = "segurity group id for ec2"
}
variable "ec2id" {
  description = "ec2 id"
}
```