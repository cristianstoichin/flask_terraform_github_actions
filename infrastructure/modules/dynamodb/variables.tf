variable "application" {
  type = string
}

variable "environment" {
  type = string
}

variable "billing_mode" {
  type = string
}

variable "read_capacity" {
  type = string
}

variable "write_capacity" {
  type = string
}

variable "projection_type" {
  type = string
}

variable "hash_key" {
  type = string
}

variable "range_key" {
  type = string
}

variable "tags" {
  type = map(any)
}

variable "attribute_sets" {
  type = list(object({
    name = string
    type = string
  }))
}

variable "global_secondary_indexes" {
  type = list(object({
    hash_key = string
    range_key = string
    index_name  = string
  }))
}