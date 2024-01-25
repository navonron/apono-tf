## enabling IAM roles for service accounts
data "tls_certificate" "cert" {
  url = var.eks_issuer
}

resource "aws_iam_openid_connect_provider" "oicd" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cert.certificates[0].sha1_fingerprint]
  url             = var.eks_issuer
  depends_on      = [data.tls_certificate.cert]
}

// IAM role and access policy for apono tagged secrets
resource "aws_iam_role" "role" {
  name = "apono-${var.eks_name}"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : { "Federated" : "arn:aws:iam::${var.aws_account}:oidc-provider/${replace(var.eks_issuer, "https://", "")}" },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : { "${replace(var.eks_issuer, "https://", "")}:sub" : "system:serviceaccount:${var.namespace}:apono" }
        }
      }
    ]
  })

  inline_policy {
    name = "apono-tagged-keys-access-policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect    = "Allow"
          Action    = ["kms:Sign"]
          Resource  = "*"
          Condition = { "StringEquals" : { "aws:ResourceTag/apono-connector-read" : "true" } }
        },
      ]
    })
  }

  inline_policy {
    name = "apono-tagged-secrets-access-policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect    = "Allow"
          Action    = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
          Resource  = "arn:aws:secretsmanager:*:${var.aws_account}:secret:*"
          Condition = { "StringEquals" : { "aws:ResourceTag/apono-connector-read" : "true" } }
        },
      ]
    })
  }

  // for IAM Managment
  inline_policy {
    name = "iam-access-policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "iam:ListPolicies",
            "iam:CreateInstanceProfile",
            "iam:ListGroups",
            "iam:ListInstanceProfiles"
          ],
          Resource = "*"
        },
        {
          Effect = "Allow"
          Action = [
            "iam:CreateInstanceProfile",
            "iam:GetRole",
            "iam:UpdateAssumeRolePolicy",
            "iam:ListRoleTags",
            "iam:TagRole",
            "iam:CreateRole",
            "iam:DeleteRole",
            "iam:AttachRolePolicy",
            "iam:PutRolePolicy",
            "iam:AddRoleToInstanceProfile",
            "iam:ListInstanceProfilesForRole",
            "iam:DetachRolePolicy",
            "iam:ListAttachedRolePolicies",
            "iam:DeleteRolePolicy",
            "iam:ListAttachedGroupPolicies",
            "iam:ListRolePolicies",
            "iam:GetRolePolicy",
            "iam:PassRole",
            "iam:GetInstanceProfile",
            "iam:CreateUser",
            "iam:CreateAccessKey",
            "iam:DeleteAccessKey",
            "iam:PutUserPolicy",
            "iam:DeleteUserPolicy",
            "iam:GetUser",
            "iam:GetUserPolicy",
            "iam:ListAttachedUserPolicies",
            "iam:ListUserPolicies",
            "iam:UpdateLoginProfile",
            "iam:ListAccessKeys",
            "iam:AttachUserPolicy",
            "iam:DetachUserPolicy",
            "iam:CreateLoginProfile"
          ]
          Resource = [
            "arn:aws:iam::*:instance-profile/*",
            "arn:aws:iam::*:role/*",
            "arn:aws:iam::*:group/*",
            "arn:aws:iam::*:user/*"
          ]
        }
      ]
    })
  }

  inline_policy {
    name = "ec2-policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        "Effect" : "Allow",
        "Action" : ["ec2:DescribeInstances", "ec2:DescribeTags", "ec2:AssociateIamInstanceProfile"],
        "Resource" : "*"
      }]
    })
  }
}

data "aws_iam_policy" "SecurityAudit" {
  arn = "arn:aws:iam::aws:policy/SecurityAudit"
}

resource "aws_iam_role_policy_attachment" "connector-security-audit" {
  role       = aws_iam_role.role.name
  policy_arn = data.aws_iam_policy.SecurityAudit.arn
}
