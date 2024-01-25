variable "name" {
  type = string
  validation {
    condition     = can(regex("^[0-9A-Za-z][A-Za-z0-9\\-_]+$", var.name))
    error_message = "EKS name must be between 1-100 characters in length. Must begin with an alphanumeric character, and must only contain alphanumeric characters, dashes and underscores."
  }
}

variable "tags" {
  type    = map(string)
  default = null
}

variable "role_arn" { type = string }
variable "snet_ids" { type = list(string) }
