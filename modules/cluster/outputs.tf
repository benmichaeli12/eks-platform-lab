output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "Kubernetes API endpoint"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_certificate_authority" {
  description = "Base64 encoded CA certificate for the Kubernetes API"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}

output "cluster_security_group_id" {
  description = "Security group EKS created for control plane and node communication"
  value       = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}

output "oidc_provider_arn" {
  description = "ARN of the cluster OIDC provider, for IRSA-based workloads"
  value       = aws_iam_openid_connect_provider.cluster.arn
}

output "oidc_provider_url" {
  description = "URL of the cluster OIDC issuer, without the https prefix"
  value       = replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")
}

output "node_role_arn" {
  description = "ARN of the node group IAM role"
  value       = aws_iam_role.node.arn
}

output "lb_controller_role_arn" {
  description = "Role assumed by the AWS Load Balancer Controller"
  value       = aws_iam_role.lb_controller.arn
}