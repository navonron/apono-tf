output "name" { value = aws_eks_cluster.eks.name }
output "host" { value = aws_eks_cluster.eks.endpoint }
output "cert" { value = aws_eks_cluster.eks.certificate_authority.0.data }
output "issuer" { value = aws_eks_cluster.eks.identity[0].oidc[0].issuer }
