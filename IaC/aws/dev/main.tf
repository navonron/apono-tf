data "aws_iam_role" "eks_role_arn" {
  name = "eksClusterRole"
}

module "apono-connector" {
  source = "../../../main/aws/apono-connector"
  eks_name = "eks-apono-dev-ron"
  eks_role_arn = data.aws_iam_role.eks_role_arn.arn
  eks_snet_ids = ["subnet-0c6c73512bb439593"]
  namespace = "apono"
  apono_token = ""
  apono_app_url = "api.apono.io"
  connector_name = "ron-aws-integration-tf"
}


