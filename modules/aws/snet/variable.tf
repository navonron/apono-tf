variable "snet" {
  type = list(object({
    vpc_id = string
    cidr   = string
    tags   = optional(map(string), null)
    az     = optional(string, null)
  }))
}
