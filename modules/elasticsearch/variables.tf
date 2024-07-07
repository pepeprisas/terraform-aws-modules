variable "region" {
  default = "eu-west-1"
}

variable "service" {}
variable "team" {}
variable "country" {}

variable "resource" {
  description = "Name of the resource"
  default = "elasticsearch"
}

variable "vpc_id" {}
variable "subnet_ids" {}
variable "cidr_blocks" {
  type        = list(string)
}
variable "route53_zone_id" {}

variable "instance_class" { default = "t3.medium.elasticsearch" }
variable "ebs_volume_size" { default = 35}
variable "ebs_volume_type" { default = "gp2"}

variable "domain_name" {}
variable "es_version" { default = "6.3"}

variable "snapshot_start_hour" { default = 0 }

variable "use_prefix" {
  description = "Flag indicating whether or not to use the domain_prefix. Default: true"
  default     = true
}

variable "domain_prefix" {
  description = "String to be prefixed to search domain. Default: tf-"
  default     = "tf-"
}

variable "dedicated_master_threshold" {
  description = "The number of instances above which dedicated master nodes will be used. Default: 10"
  default     = 10
}

variable "kms_id" {}