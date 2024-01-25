variable "iam_policy" {
  type = list(object({
    name        = string
    description = optional(string, null)
    policy = object({
      version = string
      statement = list(object({
        action = string
      }))
    })
  }))
}
