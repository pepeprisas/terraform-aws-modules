variable "region" {
  default = ""
}

variable "name" {
  default = ""
}

variable "description" {
  default = ""
} 

variable "resource" {
  default =  ""
}

variable "team" {
  default =  ""
}

variable "country" {
  default =  ""
}

variable "metric_name" {
  default = "" #"StatusCheckFailed"
}

variable "namespace" {
  default = ""
}

variable "statistic" {
  default =  ""  #"Maximum"
}

variable "instance_id" {
  default = ""
}

variable "unit" {
  default = ""
}

variable "period" {
  default = ""
}

variable "evaluation_periods" {
  default = ""
}

variable "threshold" {
  default = ""
}

variable "comparison_operator" {
  default = "" #"GreaterThanOrEqualToThreshold" 
}

variable "datapoints_to_alarm" {
  default = "" #"GreaterThanOrEqualToThreshold" 
}

variable "sns_topic" {
  default = "" #"ehread" 
}

variable "treat_missing_data" {
  default = "" # breaching
}

variable "ok_actions" {
  type    = list
  default = []
}

variable "alarm_actions" {
  type    = list
  default = []
}

variable "insufficient_data_actions" {
    type        = list
    default     = []
} 
