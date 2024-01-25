variable "iam_role" {
  type = list(object({
    name = string
    tags = optional(map(string), null)
  }))
}