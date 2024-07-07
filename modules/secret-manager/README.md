# Secret manager  Module
Create a secret manager entrance with user and passw keys

### Example

Include in your main.tf file:  
```
module "secretmanager" {
    source = "./modules/secret-manager"
    region = var.region
    name = var.freetext
    team = var.team
    country = var.country
}%                     
```

Pass the rest of the variables needed in your `variable.tf` file. For example:  
```
variable "region" {
  description = "Name of the team owner of this AWS component"
  default = "eu-west-1"
}

variable "country" {
  description="Country code https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes"
  default = "es"
}

variable "team" {
  default = "data"
}

variable "freetext"{
    description="freetext to explain the resource"
    default = "Myscecretname"
}

```
