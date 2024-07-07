## Create elastiCache Redis cluster

This example to create elastiCache Redis in mode cluster

module "elastic" {
source = "git::ssh://git@github.com/${var.githubproject}.git//modules/elasticache-cluster-redis"
  subnet_id = data.terraform_remote_state.environment_networking.outputs.private_subnet_ids[0]
  engine               = var.engine
  node_type            = var.node_type
  num_cache_nodes      = var.num_cache_nodes
  engine_version       = var.engine == "redis" ? var.engine_version : null
  port                 = var.port
  service = var.service
  environment = terraform.workspace
  team = var.team
  family = var.family
}
