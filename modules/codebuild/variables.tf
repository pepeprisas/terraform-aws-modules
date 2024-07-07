variable "region" {
  default = "eu-west-1"
}

variable "buildspec" {
  description = "freetext to explain the resource"
  default     = "./buildspec.yml"
}
variable "image" {
  description = "ECR image for this codebuild"
  default     = "968479493337.dkr.ecr.eu-west-1.amazonaws.com/esdataecr:latest"
}
variable "sonardns" {
  description = "Sonar dns url"
  default     = "sonarqube-data.example.com"
}
variable "sonarproject" {
  description = "sonar project name for this codebuild"
}
variable "githubproject" {
  description = "Github project name for this codebuild"
}
variable "name" {
  description = "Resourcename"
}
variable "country" {
  description = "Country"
}
variable "team" {
  description = "devops|dev|data"
}

variable "subnet_id" {
  description = "Subnet in the vpc"
}
variable "service" {
  description = "he name of the resource is created for"
}
variable "vpc_id" {
  description = "vpc id"
}
variable "secretid" {
  description ="Secret manager id with github credentials"
}
