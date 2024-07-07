variable "region" {
  default     = ""
}

variable "alarm_name" {
  default = ""
}

variable "service" {
  default = ""
}

variable "comparison_operator" {
  default = "" #"LessThanThreshold" 
}

variable "period" {
  default = ""
}

variable "statistic" {
  default =  ""  #"SampleCount" # "Average" # "Maximum"
}

variable "threshold" {
  default = ""
}

variable "evaluation_periods" {
  default = ""
}

variable "metric_name" {
  default = "" #"GroupInServiceInstances"  #"HTTPCode_Target_5XX_Count" # "UnHealthyHostCount" #"HealthyHostCount" #"ecs_exception"
}

variable "namespace" {
  default = ""
}

variable "actions_enabled" {
  default = ""
}

variable "alarm_description" {
  default = ""
} 

variable "insufficient_data_actions" {
    type        = list
    default     = []
} 

variable "alarm_sns" {
  type    = map
  default = { }
}

variable "dimensions" {
    type = list
    default     = []
}

variable "LoadBalancerName" {
  default  =  ""
}

variable "TargetGroup" {
  default  =  ""
}


variable "treat_missing_data" {
  default  = "" # ignore, breaching and notBreaching.
}

variable "country" {
  default  =  ""
}

variable "team" {
  default  =  ""
}

variable "resource" {
  default  =  ""
}

variable "ok_actions" {
    type = list
    default     = []
}

variable "alarm_actions" {
    type = list
    default     = []
}

variable "account" {
  default  =  ""
}

variable "user_sns" {
  default  =  ""
}