variable "application" {
  type = string
}

variable "environment" {
  type = string
}

variable "endpoint_type" {
  type = string
}

variable "hosted_zone_name" {
  type = string
}

variable "sub_domain" {
  type = string
}

variable "tags" {
  type = map(any)
}