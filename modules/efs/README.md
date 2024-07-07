# albec2 Module
Create an EFS. It includes the backup tag, so this Elastic File System will be included in AWS Backup service by default.

### Example

Include in your main.tf file:  
```
module "efs" {
  source = "git::ssh://git@github.com/${var.githubproject}.git//modules/efs"
  name = var.name
  country = var.country
  team = var.team
  subnet_ids = terraform.workspace == "production" ? data.terraform_remote_state.environment_networking.outputs.public_subnet_ids[0] : data.terraform_remote_state.environment_networking.outputs.private_subnet_ids[0]
  efs_security_group = [aws_security_group.efs-sg.id]
}
```

  
Pass the rest of the variables needed in your `variable.tf` file. For example:  
```
variable "name"{
  description="Name of the cluster"
}
variable "country"{
  description="Country code https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes"
}
variable "team" {
  description = "devops|dev|data"
}

variable "subnet_ids" {
  description = "Subnet id"
}

variable "efs_security_group" {
  description = "Security group for access to EFS"
}
```