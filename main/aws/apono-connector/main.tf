data "aws_caller_identity" "aws_account" {
}

data "aws_iam_policy" "SecurityAudit" {
  arn = "arn:aws:iam::aws:policy/SecurityAudit"
}

module "eks" {
  source   = "../../../modules/aws/eks"
  name     = var.eks_name
  tags     = var.eks_tags
  role_arn = var.eks_role_arn
  snet_ids = var.eks_snet_ids
}

// set EKS service account role and grant permission to resources with apono-connector-read: true tag
module "iam_role" {
  source = "../../../modules/aws/iam_role"
  name   = "${var.service_account_name}-${var.connector_name}"
  assume_role_policy_json = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::${data.aws_caller_identity.aws_account.account_id}:oidc-provider/${replace(module.eks.issuer, "https://", "")}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${replace(module.eks.issuer, "https://", "")}:sub" : "system:serviceaccount:${var.namespace}:${var.service_account_name}"
          }
        }
      }
    ]
  })

  inline_policies = [
    {
      name = "apono-tagged-keys-access-policy",
      policy_json = jsonencode({
        "Version" : "2012-10-17",
        "Statement" : [
          {
            "Effect" : "Allow",
            "Action" : ["kms:Sign"],
            "Resource" : "*",
            "Condition" : {
              "StringEquals" : { "aws:ResourceTag/apono-connector-read" : "true" }
            }
          }
        ]
      })
    },
    {
      name = "apono-tagged-secrets-access-policy",
      policy_json = jsonencode({
        "Version" : "2012-10-17",
        "Statement" : [
          {
            "Effect" : "Allow",
            "Action" : ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"],
            "Resource" : "arn:aws:secretsmanager:*:${data.aws_caller_identity.aws_account.account_id}:secret:*",
            "Condition" : {
              "StringEquals" : { "aws:ResourceTag/apono-connector-read" : "true" }
            }
          }
        ]
      })
    },
    {
      name = "iam-access-policy",
      policy_json = jsonencode({
        "Version" : "2012-10-17",
        "Statement" : [
          {
            "Effect" : "Allow",
            "Action" : [
              "iam:ListPolicies",
              "iam:CreateInstanceProfile",
              "iam:ListGroups",
              "iam:ListInstanceProfiles"
            ],
            "Resource" : "*"
          },
          {
            "Effect" : "Allow",
            "Action" : [
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
            ],
            "Resource" : [
              "arn:aws:iam::*:instance-profile/*",
              "arn:aws:iam::*:role/*",
              "arn:aws:iam::*:group/*",
              "arn:aws:iam::*:user/*"
            ]
          }
        ]
      })
    },
    {
      name        = "ec2-policy",
      policy_json = jsonencode({
        "Version" : "2012-10-17",
        "Statement" : [
          {
            "Effect" : "Allow",
            "Action" : [ "ec2:DescribeInstances","ec2:DescribeTags","ec2:AssociateIamInstanceProfile" ],
            "Resource" : "*"
          }
        ]
      })
    }
  ]
}


module "iam_role_policy_attachment" {
  source     = "../../../modules/aws/iam_role_policy_attachment"
  role       = module.iam_role.name
  policy_arn = data.aws_iam_policy.SecurityAudit.arn
}

// agent deployment
module "apono_agent_helm" {
  source         = "../../../modules/apono/agent_helm"
  namespace      = var.namespace
  account_id     = data.aws_caller_identity.aws_account.account_id
  eks_name       = module.eks.name
  apono_token    = var.apono_token
  apono_app_url  = var.apono_app_url
  connector_name = var.connector_name
  eks_host       = module.eks.host
  eks_cert       = module.eks.cert
}
