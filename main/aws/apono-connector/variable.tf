variable "eks_name" {
  type = string
  validation {
    condition     = can(regex("^[0-9A-Za-z][A-Za-z0-9\\-_]+$", var.eks_name))
    error_message = "EKS name must be between 1-100 characters in length. Must begin with an alphanumeric character, and must only contain alphanumeric characters, dashes and underscores."
  }
}

variable "eks_tags" {
  type    = map(string)
  default = null
}

variable "eks_role_arn" { type = string }
variable "eks_snet_ids" { type = list(string) }
variable "service_account_name" { type = string }
variable "namespace" { type = string }
variable "apono_token" { type = string }
variable "apono_app_url" { type = string }
variable "connector_name" { type = string }

