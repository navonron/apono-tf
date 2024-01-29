variable "name" { type = string }
variable "tags" {
  type    = map(string)
  default = null
}
variable "assume_role_policy_json" { type = string }

variable "inline_policies" {
  type = list(object({
    name        = string
    policy_json = string
  }))
}
