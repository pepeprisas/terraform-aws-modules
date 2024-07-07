# Certificate manager Module
Create a certificate with ACM in the specified region.

### Example

Include in your main.tf file:  
```
module "certificate_manager" {
    source       = "git::ssh://git@github.com/${var.githubproject}.git//modules/certificate-manager"
    freetext     = var.freetext
    team         = var.team
    country      = var.country
    domain_name  = var.domain_name
    zone_name    = var.zone_name
    private_zone = var.private_zone
}
```

Pass the rest of the variables needed in your `variable.tf` file. For example:  
```
variable "region" {
  description = "Name of the region"
}

variable "country" {
  description= "Country code https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes"
}

variable "team" {
  description = "devops|dev|data"
}

variable "private_zone" {
  description = "Select if is a private route53 zone. Most of the times will be public (false)"
  default = "false"
}

variable "domain_name" {
    description = "Domain name"
    default = "*.example.com"
}

variable "zone_name" {
    description = "Route53 zone name"
    default = "example.com"
}

variable "freetext" {
    description = "Freetext to explain the certificate resource"
    default = "example"
}
```

Copy the `Makefile` to your new project and execute it in this way:  
```
$ make deployService DOMAIN=example ENVIRONMENT=production TEAM=devops COUNTRY=uk REGION=us-east-1
```

This will deploy the certificate with the correct terraform ket tfstate file.
