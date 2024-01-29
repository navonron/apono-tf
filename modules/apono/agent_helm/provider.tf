provider "kubernetes" {
  host                   = var.eks_host
  cluster_ca_certificate = base64decode(var.eks_cert)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", var.eks_name]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = var.eks_host
    cluster_ca_certificate = base64decode(var.eks_cert)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", var.eks_name]
      command     = "aws"
    }
  }
}
