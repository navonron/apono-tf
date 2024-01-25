data "aws_caller_identity" "aws_account" {
}

module "eks" {
  source     = "../../../modules/aws/eks"
  name       = var.eks_name
  tags       = var.eks_tags
  role_arn   = var.eks_role_arn
  snet_ids = var.eks_snet_ids
}

module "apono-svca" {
  source      = "../../../modules/aws/apono_eks_svca"
  aws_account = data.aws_caller_identity.aws_account.account_id
  eks_issuer  = module.eks.issuer
  eks_name    = module.eks.name
  namespace   = var.namespace
}

// agent deployment
resource "kubernetes_namespace_v1" "apono-namespace" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "apono-connector" {
  name       = "apono-connector"
  repository = local.connector_helm_repo
  chart      = local.connector_helm_chart
  version    = local.connector_helm_chart_version
  namespace  = kubernetes_namespace_v1.apono-namespace.metadata[0].name

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
    value = var.APONO_WEBSOCKET_URL
  }

  set {
    name  = "apono.connectorId"
    value = var.CONNECTOR_ID
  }
}
