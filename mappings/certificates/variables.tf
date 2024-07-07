
variable "certificates" {
  type = map
  default = {
    "staging" = "arn:aws:acm:eu-west-1:968479493337:certificate/984d4dac-843f-46e1-b8df-958b535f7059",
    "production" = "arn:aws:acm:eu-west-1:968479493337:certificate/d5c426d4-4089-42cb-90fe-59f8680287bc"
  }
}
