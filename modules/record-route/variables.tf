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
  default     = "60"
}
variable "type" {
  description = "type for hosted zone"
  default     = "CNAME"
}