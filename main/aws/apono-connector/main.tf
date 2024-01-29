data "aws_caller_identity" "aws_account" {
}

module "eks" {
  source     = "../../../modules/aws/eks"
  name       = var.eks_name
  tags       = var.eks_tags
  role_arn   = var.eks_role_arn
  snet_ids = var.eks_snet_ids
}

// set EKS service account role and grant permission to resources with apono-connector-read: true tag
module "iam_role" {
  source = "../../../modules/aws/iam_role"
    iam_role = [{
    name = "${var.service_account_name}-${var.connector_name}"
    assume_role_policy_json = <<EOT
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
            "Federated": "arn:aws:iam::${local.aws_account_id}:oidc-provider/${replace(module.eks.issuer, "https://", "")}"
          },
          "Action": "sts:AssumeRoleWithWebIdentity",
          "Condition": {
            "StringEquals": {
              "${replace(module.eks.issuer, "https://", "")}:sub": "system:serviceaccount:${var.namespace}:${var.service_account_name}"
            }
          }
        }
      ]
    }
    EOT
  }]
}




  
  # inline_policy {
  #   name = "apono-tagged-keys-access-policy"
  #   policy = jsonencode({
  #     Version = "2012-10-17"
  #     Statement = [
  #       {
  #         Effect = "Allow"
  #         Action = [ "kms:Sign" ]
  #         Resource = "*"
  #         Condition = { "StringEquals": {"aws:ResourceTag/apono-connector-read": "true"} }
  #       },
  #     ]
  #   })
  # }
  
  # inline_policy {
  #   name = "apono-tagged-secrets-access-policy"

  #   policy = jsonencode({
  #     Version = "2012-10-17"
  #     Statement = [
  #       {
  #         Effect = "Allow"
  #         Action = [ "secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
  #         Resource = "arn:aws:secretsmanager:*:${local.aws_account_id}:secret:*"
  #         Condition = { "StringEquals": {"aws:ResourceTag/apono-connector-read": "true"} }
  #       },
  #     ]
  #   })
  # }

  # inline_policy {
  #   name = "iam-access-policy"
  #   policy = jsonencode({
  #     Version = "2012-10-17"
  #     Statement = [
  #       {
  #           Effect = "Allow"
  #           Action = [
  #               "iam:ListPolicies",
  #               "iam:CreateInstanceProfile",
  #               "iam:ListGroups",
  #               "iam:ListInstanceProfiles"
  #           ],
  #           Resource = "*"
  #       },
  #       {
  #           Effect = "Allow"
  #           Action = [
  #               "iam:CreateInstanceProfile",
  #               "iam:GetRole",
  #               "iam:UpdateAssumeRolePolicy",
  #               "iam:ListRoleTags",
  #               "iam:TagRole",
  #               "iam:CreateRole",
  #               "iam:DeleteRole",
  #               "iam:AttachRolePolicy",
  #               "iam:PutRolePolicy",
  #               "iam:AddRoleToInstanceProfile",
  #               "iam:ListInstanceProfilesForRole",
  #               "iam:DetachRolePolicy",
  #               "iam:ListAttachedRolePolicies",
  #               "iam:DeleteRolePolicy",
  #               "iam:ListAttachedGroupPolicies",
  #               "iam:ListRolePolicies",
  #               "iam:GetRolePolicy",
  #               "iam:PassRole",
  #               "iam:GetInstanceProfile",
  #               "iam:CreateUser",
  #               "iam:CreateAccessKey",
  #               "iam:DeleteAccessKey",
  #               "iam:PutUserPolicy",
  #               "iam:DeleteUserPolicy",
  #               "iam:GetUser",
  #               "iam:GetUserPolicy",
  #               "iam:ListAttachedUserPolicies",
  #               "iam:ListUserPolicies",
  #               "iam:UpdateLoginProfile",
  #               "iam:ListAccessKeys",
  #               "iam:AttachUserPolicy",
  #               "iam:DetachUserPolicy",
  #               "iam:CreateLoginProfile"
  #           ]
  #           Resource = [
  #               "arn:aws:iam::*:instance-profile/*",
  #               "arn:aws:iam::*:role/*",
  #               "arn:aws:iam::*:group/*",
  #               "arn:aws:iam::*:user/*"
  #           ]
  #       }
  #     ]
  #   })
  # }
  
  # inline_policy {
  #   name = "ec2-policy"
  #   policy = jsonencode({
  #     Version = "2012-10-17"
  #     Statement = [{
  #       "Effect": "Allow",
  #       "Action": [ "ec2:DescribeInstances","ec2:DescribeTags","ec2:AssociateIamInstanceProfile" ],
  #       "Resource": "*"
  #     }]
  #   })
  # }






data "aws_iam_policy" "SecurityAudit" {
  arn = "arn:aws:iam::aws:policy/SecurityAudit"
}

resource "aws_iam_role_policy_attachment" "connector-security-audit" {
  role       = "${aws_iam_role.apono-connector.name}"
  policy_arn = "${data.aws_iam_policy.SecurityAudit.arn}"
}



module "apono-svca" {
  source      = "../../../modules/aws/apono_eks_svca"
  aws_account = data.aws_caller_identity.aws_account.account_id
  eks_issuer  = module.eks.issuer
  eks_name    = module.eks.name
  namespace   = var.namespace
}

resource "helm_release" "apono-connector" {
  name       = "apono-connector"
  repository = local.connector_helm_repo
  chart      = local.connector_helm_chart
  version    = local.connector_helm_chart_version
  namespace  = var.namespace

  set {
    name  = "serviceAccount.name"
    value = var.namespace
  }

  set {
    name  = "serviceAccount.awsRoleAccountId"
    value = data.aws_caller_identity.aws_account.account_id
  }

  set {
    name  = "serviceAccount.awsRoleName"
    value = "apono-${var.eks_name}"
  }

  set {
    name  = "image.tag"
    value = "v1.5.3"
  }

  set {
    name  = "apono.token"
    value = var.apono_token
  }

  set {
    name  = "apono.url"
    value = var.apono_app_url
  }

  set {
    name  = "apono.connectorId"
    value = var.connector_name
  }
}


## add secret to save the connector cridintials to resources on