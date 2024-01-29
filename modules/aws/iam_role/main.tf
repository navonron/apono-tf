resource "aws_iam_role" "role" {
  name = var.name
  tags = var.tags
  assume_role_policy = var.assume_role_policy_json

  dynamic "inline_policy" {
    for_each = { for idx, policy in var.inline_policies : idx => policy }
    content {
      name   = inline_policy.value.name
      policy = inline_policy.value.policy_json
    }
  }
}
