variable "subnet_id" {
  description = "Subnet ID"
}

variable "service" {
  description = "Name of the service deployed"
}

variable "create_sg" {
  description = " Determine if the EC2 has own Security Group defined. If value is 1 a new SQ is created, but it will need to attach the ingress rule. Value 0 there is no SG to create."
}

variable "ami_name" {
  description = "Name of the AMI to deploy to the instance"
}

variable "instance_type" {
  description = "Instance type to deploy"
}

variable "sg_ids" {
  description = "List of Security groups to apply to the deployed instance. It will be aplied if create_sg is 0"
  default = []
}

variable "instance_profile_role" {
  description = "The IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile"
}

variable "from_port" {
  description = "The start port of ingress rule to connect to connect-sg"
}

variable "to_port" {
  description = "The end port of ingress rule to connect to connect-sg"
}

variable "ipblocks" {
  type = list(string)
  description = "ips block to allo ingress"
}
variable "account"{
}

variable "userdata"{
  description = "userdatafile if apply"
  default = ""
}

variable "volume_type"{
  description = "Type of volumen for ec2 standard, gp3, gp2, io1, io2, sc1, or st1"
  default = "gp3"
}

variable "volume_size"{
  description = "The size of the volume in gibibytes (GiB)"
}

variable "volume_iops"{
  description = "The amount of provisioned IOPS. This is only valid for volume_type of io1/io2, and must be specified if using that type"
}

variable "freetext"{
  description = "freetext to explain the resource"
  default = null
}
