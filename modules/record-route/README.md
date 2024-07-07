# albec2 Module
Create an alb for an record in a Route53 hosted zone

### Example

Include in your main.tf file:  
```
module "recordRoute53" {
  source  = "./modules/recordRoute/"
  dnsname = module.alb_ec2.dnsname
  name    = var.urlname
  zoneid  = var.zoneid
  type = var.type

}
```

  
Pass the rest of the variables needed in your `variable.tf` file. For example:  
```
variable "dnsname" {
  description = "dns name for elb"
}
variable "name" {
  description = " name for record"
}
variable "zoneid" {
  description = "route 53 zone id"
}
variable "ttl" {
  description = "ttl time in seconds"
  default = "60"
}
variable "type" {
  description = "type for hosted zone"
  default     = "CNAME"
}
```