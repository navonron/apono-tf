resource "kubernetes_namespace_v1" "namespace" {
  metadata {
    name = var.namespace
  }
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
    value = var.account_id
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