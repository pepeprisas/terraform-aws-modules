# ec2 Module
Create an EC2 with several options and a SG attached to it with CIDR Block to ingress.  
Only AMI's that start with `devops/...` name are allowed.  

### Example

Include in your main.tf file:  
```
module "ec2" {
  source = "git::ssh://git@github.com/${var.githubproject}.git//modules/ec2-instance"
  country = var.country
  team = var.team
  freetext = var.freetext
  instance_profile_role=var.instance_profile_role
  subnet_id=var.subnet_id
  to_port=var.to_port
  from_port=var.from_port
  ipblocks=var.ipblocks
  instance_type=var.instance_type
  ami_name=var.ami_name
  create_sg=var.create_sg
  userdata=file(var.userdata)
  volume_iops=var.volume_iops
  volume_size=var.volume_size
  volume_type=var.volume_type
}
```

In your variables you need to pass to `userdata` one userdata file. If you don't need to pass user data to the instance on boot, just create one `datascript.sh` file that do nothing:  
```
#!/usr/bin/bash
exit 0
```

*ToDo* - Create one condition in module to avoid this

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

variable "service" {
  default = "yourService"
}

variable "freetext"{
    description="freetext to explain the resource"
    default = "myEC2Test"
}

variable "subnet_id" {
  description = "Subnet ID"
  default="subnet-...."
}

variable "create_sg" {
  description = " Determine if the EC2 has own Security Group defined. If value is 1 a new SQ is created, but it will need to attach the ingress rule. Value 0 there is no SG to create."
  default = 0
}

variable "ami_name" {
  description = "Name of the AMI you want to deploy to the instance"
}

variable "instance_type" {
  description = "Instance type to deploy"
  default = "t2.small"
}

variable "sg_ids" {
  description = "List of Security groups to apply to the deployed instance. It will be aplied if create_sg is 0"
  default = []
}

variable "instance_profile_role" {
  description = "The IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile"
  default = "ecsInstanceRole"
}

variable "from_port" {
  description = "The start port of ingress rule to connect to connect-sg"
  default = "0"
}

variable "to_port" {
  description = "The end port of ingress rule to connect to connect-sg"
  default = "0"
}

variable "ipblocks" {
  type    = list(string)
  description="ips block to allow ingress"
  default = []
}

variable "userdata"{
  description="userdatafile if apply"
  default = "datascript.sh"
}

variable "volume_type"{
  description="Type of volumen for ec2 standard, gp2, io1, io2, sc1, or st1"
  default = "gp2"
}

variable "volume_size"{
  description="The size of the volume in gibibytes (GiB)"
  default = "30"
}

variable "volume_iops"{
  description="he amount of provisioned IOPS. This is only valid for volume_type of io1/io2, and must be specified if using that type"
  default = ""
}
```
