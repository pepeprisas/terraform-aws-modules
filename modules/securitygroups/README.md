# s3 Module
Create a Security Group with one or more ingress/egress rules (only CIDR option)

Example 
```

module "sg_emr_master_model_pipeline" {
	source      = "git::ssh://git@github.com/${var.githubproject}.git//modules/securitygroups"
    region      = var.region
    name        = "emr-master-model-pipeline"
    description = "SG for model pipeline EMR master"
	resource    = var.resource
  	team        = var.team
	country     = var.country
	vpc_id      = local.vpc_id[local.environment]

	ingress_with_cidr_blocks = [
		{
			from_port   = 22
			to_port     = 22
			protocol    = "tcp"
			cidr_block = "10.9.0.0/16"
			description = "SSH access from VPN network"
		},
	    {
			from_port   = 22
			to_port     = 22
			protocol    = "tcp"
			cidr_block  = "172.16.0.0/16"
			description = "Access from client subnets"
	    }
	]

	egress_with_cidr_blocks = [
		{
			from_port   = 0
			to_port     = 0
			protocol    = "-1"
			cidr_block  = "0.0.0.0/0"
			description = "default egress rule"
		}
	]
}

```
