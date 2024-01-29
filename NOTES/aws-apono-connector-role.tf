# // IAM role and access policy for apono tagged secrets

# # set temporary security credentials to make API calls to any AWS service for the AWS connector -- 
# resource "aws_iam_role" "apono-connector" {
#   name     = "${var.service_account_name}-${var.CONNECTOR_ID}"

#   # policy that grants an entity permission to assume the role
#   #### service account role: https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html
#   assume_role_policy = jsonencode({
#     "Version" : "2012-10-17",
#     "Statement" : [
#       {
#         "Effect" : "Allow",
#         # the principal that is allowed or denied access to a resource.
#         "Principal" : { "Federated" : "arn:aws:iam::${local.aws_account_id}:oidc-provider/${local.oidc_provider}" }, 
#         # AWS Security Token Service (STS)
#         # AssumeRoleWithWebIdentity:
#         # returns a set of temporary security credentials for users who have been auth
#         # in a mobile or web app with a web identity provider.
#         # example providers: OAuth 2.0 providers Login with Amazon and Facebook, or any OpenID
#         # AssumeRoleWithWebIdentity used to make API calls to any AWS service
#         "Action" : "sts:AssumeRoleWithWebIdentity", 
#         "Condition" : {
#           "StringEquals" : { "${local.oidc_provider}:sub" : "system:serviceaccount:${var.namespace}:${var.service_account_name}" }
#         }
#       }
#     ]
#   })
  
#   # defining set of IAM inline policies associated with the IAM role
#   inline_policy {
#     name = "apono-tagged-keys-access-policy"

#     # controls permission to produce a digital signature for a message
#     policy = jsonencode({
#       Version = "2012-10-17"
#       Statement = [
#         {
#           Effect = "Allow"
#           Action = [ "kms:Sign" ]
#           Resource = "*"
#           Condition = { "StringEquals": {"aws:ResourceTag/apono-connector-read": "true"} }
#         },
#       ]
#     })
#   }
  
#   inline_policy {
#     name = "apono-tagged-secrets-access-policy"

#     policy = jsonencode({
#       Version = "2012-10-17"
#       Statement = [
#         {
#           Effect = "Allow"
#           Action = [ "secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
#           Resource = "arn:aws:secretsmanager:*:${local.aws_account_id}:secret:*"
#           Condition = { "StringEquals": {"aws:ResourceTag/apono-connector-read": "true"} }
#         },
#       ]
#     })
#   }

#   // for IAM Managment
#   inline_policy {
#     name = "iam-access-policy"
#     policy = jsonencode({
#       Version = "2012-10-17"
#       Statement = [
#         {
#             Effect = "Allow"
#             Action = [
#                 "iam:ListPolicies",
#                 "iam:CreateInstanceProfile",
#                 "iam:ListGroups",
#                 "iam:ListInstanceProfiles"
#             ],
#             Resource = "*"
#         },
#         {
#             Effect = "Allow"
#             Action = [
#                 "iam:CreateInstanceProfile",
#                 "iam:GetRole",
#                 "iam:UpdateAssumeRolePolicy",
#                 "iam:ListRoleTags",
#                 "iam:TagRole",
#                 "iam:CreateRole",
#                 "iam:DeleteRole",
#                 "iam:AttachRolePolicy",
#                 "iam:PutRolePolicy",
#                 "iam:AddRoleToInstanceProfile",
#                 "iam:ListInstanceProfilesForRole",
#                 "iam:DetachRolePolicy",
#                 "iam:ListAttachedRolePolicies",
#                 "iam:DeleteRolePolicy",
#                 "iam:ListAttachedGroupPolicies",
#                 "iam:ListRolePolicies",
#                 "iam:GetRolePolicy",
#                 "iam:PassRole",
#                 "iam:GetInstanceProfile",
#                 "iam:CreateUser",
#                 "iam:CreateAccessKey",
#                 "iam:DeleteAccessKey",
#                 "iam:PutUserPolicy",
#                 "iam:DeleteUserPolicy",
#                 "iam:GetUser",
#                 "iam:GetUserPolicy",
#                 "iam:ListAttachedUserPolicies",
#                 "iam:ListUserPolicies",
#                 "iam:UpdateLoginProfile",
#                 "iam:ListAccessKeys",
#                 "iam:AttachUserPolicy",
#                 "iam:DetachUserPolicy",
#                 "iam:CreateLoginProfile"
#             ]
#             Resource = [
#                 "arn:aws:iam::*:instance-profile/*",
#                 "arn:aws:iam::*:role/*",
#                 "arn:aws:iam::*:group/*",
#                 "arn:aws:iam::*:user/*"
#             ]
#         }
#       ]
#     })
#   }
  
#   inline_policy {
#     name = "ec2-policy"
#     policy = jsonencode({
#       Version = "2012-10-17"
#       Statement = [{
#         "Effect": "Allow",
#         "Action": [ "ec2:DescribeInstances","ec2:DescribeTags","ec2:AssociateIamInstanceProfile" ],
#         "Resource": "*"
#       }]
#     })
#   }
# }

# # grants access to read security configuration metadata.
# # it is useful for software that audits the configuration of an AWS account.
# data "aws_iam_policy" "SecurityAudit" {
#   arn = "arn:aws:iam::aws:policy/SecurityAudit"
# }

# resource "aws_iam_role_policy_attachment" "connector-security-audit" {
#   role       = "${aws_iam_role.apono-connector.name}"
#   policy_arn = "${data.aws_iam_policy.SecurityAudit.arn}"
# }


# #### role - type of IAM identity that can be authenticated and authorized to utilize an AWS resource
# #### policy - defines the permissions of the IAM identity