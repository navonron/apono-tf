resource "aws_eks_cluster" "eks" {
  name     = var.name
  tags     = var.tags
  role_arn = var.role_arn
  vpc_config {
    subnet_ids = var.snet_ids
  }
}
