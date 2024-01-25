variable "vpc" {
  type = list(object({
    cidr                 = string
    tags                 = optional(map(string), null)
    enable_dns_support   = optional(bool, true)
    enable_dns_hostnames = optional(bool, true)
  }))
}
