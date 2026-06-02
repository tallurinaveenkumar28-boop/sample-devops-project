output "cluster_name"     { value = aws_eks_cluster.main.name }
output "cluster_endpoint" { value = aws_eks_cluster.main.endpoint; sensitive = true }
output "cluster_ca_data"  { value = aws_eks_cluster.main.certificate_authority[0].data; sensitive = true }
output "cluster_sg_id"    { value = aws_security_group.cluster.id }
output "node_group_arn"   { value = aws_eks_node_group.main.arn }
output "oidc_provider_arn" { value = aws_iam_openid_connect_provider.eks.arn }
output "oidc_provider_url" { value = aws_iam_openid_connect_provider.eks.url }
output "ecr_repo_url"     { value = aws_ecr_repository.app.repository_url }
