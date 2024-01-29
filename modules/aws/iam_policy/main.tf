resource "aws_iam_policy" "policy" {
  for_each    = { for idx, policy in var.iam_policy : idx => policy }
  name        = each.value.name
  description = each.value.description

  policy = jsonencode({
    Version = each.value.policy.version
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
