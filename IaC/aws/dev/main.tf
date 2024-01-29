data "aws_iam_role" "eks_role_arn" {
  name = "eksClusterRole"
}

module "apono-connector" {
  source = "../../../main/aws/apono-connector"
  eks_name = "eks-apono-dev"
  eks_role_arn = data.aws_iam_role.eks_role_arn.arn
  eks_snet_ids = ["subnet-0c6c73512bb439593", "subnet-06c46b0b10eec4be6"]
  service_account_name = "apono"
  
  
  namespace = "apono"
  apono_token = "ebc98eb9-ec5b-4f71-9d85-fecd223d5a15"
  apono_app_url = "api.apono.io"
  connector_name = "aws-integration-tf-ron"
}
