variable "environment" {
  default = "staging"
}
variable "region" {
    description="Country code https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes"
    default = "eu-west-1"
}
variable "name"{
    description="Name with free text to describe the KMS alias name"
}
variable "country"{
    description="Country code https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes"
}
variable "resource" {
    description = "Name of the resource"
    default = "rds-mariadb"
}
variable "team" {
    description = "devops|dev|data"
}

variable "service" {
  description = "Name of the service deployed"
}

variable "availability_zone" {
  default = "eu-west-1a"
}

variable logfiles {
  type = "list"
  default = ["postgresql"]
}

variable subnet_ids {
}


variable "multi_az" { default = false }

variable "instance_class" {}
variable "allocated_storage" { default = "100"}

variable "database_name" {}
variable "database_username" {}
variable "database_password" {}

variable "hostname" {}
variable "vpc_id" {}
variable "route53_zone_id" {}

variable sg_cidr_blocks {
  type = "list"
  default = ["10.8.0.0/16", "10.9.0.0/16"]
}
variable "rds_cert" {
  description = "Certifate used by Database, given by AWS"
  default = "rds-ca-2019"
}

variable "engine_version" {
  description = "Engine version for PostgreSQL"
}

variable "kms_key" {
  description = "ID of the KMS key  used to encryupt the database"
}

variable "cpu_alarm_active" {
  type        = string
  default     = false
  description = "Activate or deactivate CPU alarm for RDS database"
}

variable "disk_alarm_active" {
  type        = string
  default     = false
  description = "Activate or deactivate Disk alarm for RDS database"
}

variable "memory_alarm_active" {
  type        = string
  default     = false
  description = "Activate or deactivate Memory alarm for RDS database"
}

variable "connection_count_alarm_active" {
  type        = string
  default     = false
  description = "Activate or deactivate Connection Count alarm for RDS database"
}

variable "alarm_evaluation_period" {
  type        = string
  default     = "5"
  description = "The evaluation period over which to use when triggering alarms."
}

variable "alarm_statistic_period" {
  type        = string
  default     = "60"
  description = "The number of seconds that make each statistic period."
}

variable "alarm_anomaly_period" {
  type        = string
  default     = "600"
  description = "The number of seconds that make each evaluation period for anomaly detection."
}

variable "alarm_anomaly_band_width" {
  type        = string
  default     = "2"
  description = "The width of the anomaly band, default 2.  Higher numbers means less sensitive."
}

variable "actions_alarm" {
  type        = list
  default     = []
  description = "A list of actions to take when alarms are triggered. Will likely be an SNS topic for event distribution."
}

variable "actions_ok" {
  type        = list
  default     = []
  description = "A list of actions to take when alarms are cleared. Will likely be an SNS topic for event distribution."
}

variable "cpu_utilization_too_high_threshold" {
  type        = string
  default     = "90"
  description = "Alarm threshold for the 'highCPUUtilization' alarm"
}

variable "cpu_credit_balance_too_low_threshold" {
  type        = string
  default     = "100"
  description = "Alarm threshold for the 'lowCPUCreditBalance' alarm"
}

variable "disk_queue_depth_too_high_threshold" {
  type        = string
  default     = "64"
  description = "Alarm threshold for the 'highDiskQueueDepth' alarm"
}

variable "disk_free_storage_space_too_low_threshold" {
  type        = string
  default     = "10000000000" // 10 GB
  description = "Alarm threshold for the 'lowFreeStorageSpace' alarm"
}

variable "disk_burst_balance_too_low_threshold" {
  type        = string
  default     = "100"
  description = "Alarm threshold for the 'lowEBSBurstBalance' alarm"
}

variable "memory_freeable_too_low_threshold" {
  type        = string
  default     = "256000000" // 256 MB
  description = "Alarm threshold for the 'lowFreeableMemory' alarm"
}

variable "memory_swap_usage_too_high_threshold" {
  type        = string
  default     = "256000000" // 256 MB
  description = "Alarm threshold for the 'highSwapUsage' alarm"
}
