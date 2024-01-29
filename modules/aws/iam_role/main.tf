resource "aws_iam_role" "role" {
  for_each = { for idx, role in var.iam_role : idx => role }
  name = each.value.name
  tags = each.value.tags
  assume_role_policy = jsondecode(each.value.assume_role_policy_json)
}
