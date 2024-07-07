variable "service" {
  description = "Name of the service which is using this component"
}
variable "environment" {
  description = "Environment where the log group will be deployed. staging,production, test..."
}

variable "team" {
  description = "Team owner of the component that will be deployed."
  default = "devops"
}
