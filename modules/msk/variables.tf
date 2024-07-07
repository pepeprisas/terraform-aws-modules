variable "service" {
  description = "MSK associated name."
}

variable "environment" {
  description = "Deployment environment"
}

variable "team" {
  description = "Team owner of the MSK deployed."
  default = "devops"
}

variable "subnets" {
  description = "List of subnets to deploy MSK cluster"
}

variable "kafka_version" {
  description = "Kafka version to deploy in cluster"
  default = "2.2.1"
}

variable "number_of_broker_nodes" {
  description = "The desired total number of broker nodes in the kafka cluster. It must be a multiple of the number of specified client subnets."
  default = 3
}

variable "node_instance_type" {
  description = "Specify the instance type to use for the kafka brokers."
  default = "kafka.m5.large"
}

variable "node_ebs_volume_size" {
  description = "The size in GiB of the EBS volume for the data drive on each broker node."
  default = 200
}

