variable "application" {
  type = string
}

variable "environment" {
  type = string
}

variable "tags" {
  type = map(any)
}

variable "policy_statements" {
  type = list(object({
    actions = list(string)
    resources = list(string)
    effect  = string
  }))
}