variable "region" {
  default = "eu-west-1"
}

variable "subnet_id" {
  description = "Subnet in the vpc"
}
variable "country" {
  description = "Country code https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes"
}
variable "resource" {
  description = "Name of the resource"
}

variable "service" {
  description = "Name of the service deployed"
}
variable "sg" {
  description = "sg from main"
}
variable "efs_id" {
  description = "efs id"
}
variable "masterec2type" {
  description = "ec2 type for master node on EMR"
}
variable "clusterec2type" {
  description = "ec2 type for cluster nodes on EMR"
}
variable "s3emr" {
  description = "s3 for data user data"
  default     = "es-data-staging-s3-emr"
}
variable "applications" {
  description = "applications for emr cluster"
  type        = list(string)
  default     = ["Spark", "Hive"]
}
variable "bid_price" {
  description = "maximum price for ec2 cluster spot instance"
  default     = "0.07"
}
variable "policydata" {
  description = "data file with policy for emr cluster"
}
variable "configurationemr" {
  description = "Configuration file for EMR"
}