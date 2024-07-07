# albec2 Module
Create an EFS access point. The access point creates an access to a specific directory in your EFS.

### Example

Include in your main.tf file:  
```
resource "aws_efs_access_point" "conf" {
  file_system_id = module.efs.efs_id
  posix_user {
    gid = 1000
    uid = 1000
  }
  root_directory {
    path = "/conf"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = 755
    }
  }
  tags = {
    Environment = terraform.workspace
    Name  = "${var.country}-${var.team}-${terraform.workspace}-accessPointConf-${var.name}"
    Country = var.country
    Resource = "accessPoint"
    Environment = terraform.workspace
    Team = var.team
  }
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

variable "access_point_list" {
  description = "List of maps with the access point parameters."
}
```