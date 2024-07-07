variable "service" {
  description = "Elasticache associated name."
}

variable "environment" {
  description = "Deployment environment"
}

variable "team" {
  description = "devops|dev|data"
  default = "devops"
}

variable "subnet_id" {
  description = "Subnet Id"
}

variable "engine" {
  description = "Name of the cache engine to be used for this cache cluster."
}

variable "family" {
  description = "The family of the ElastiCache parameter group."
}

variable "node_type" {
  description = "Type of instance of the node deployed."
  default = "cache.m5.large"
}

variable "num_cache_nodes" {
  # AWS' optimiced ECS amazon linux 2 based
  description = "The initial number of cache nodes that the cache cluster will have. For Redis, this value must be 1. For Memcache, this value must be between 1 and 20."
  default = 1
}

variable "engine_version" {
  description = "Version number of the cache engine to be used."
}

variable "port" {
  description = "The port number on which each of the cache nodes will accept connections. For Memcache the default is 11211, and for Redis the default port is 6379."
}

