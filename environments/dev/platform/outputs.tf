output "vpc_id" {
  description = "ID of the VPC"
  value       = module.network.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs where nodes and pods run"
  value       = module.network.private_subnet_ids
}

output "isolated_subnet_ids" {
  description = "Isolated subnet IDs where the database runs"
  value       = module.network.isolated_subnet_ids
}

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.cluster.cluster_name
}

output "cluster_endpoint" {
  description = "Kubernetes API endpoint"
  value       = module.cluster.cluster_endpoint
}

output "cluster_certificate_authority" {
  description = "Base64 encoded CA certificate for the Kubernetes API"
  value       = module.cluster.cluster_certificate_authority
  sensitive   = true
}

output "oidc_provider_arn" {
  description = "ARN of the cluster OIDC provider"
  value       = module.cluster.oidc_provider_arn
}

output "cluster_security_group_id" {
  description = "Security group for control plane and node communication"
  value       = module.cluster.cluster_security_group_id
}

output "aws_region" {
  description = "Region the platform is deployed in"
  value       = var.aws_region
}

output "state_bucket" {
  description = "Bucket holding this root's state, for downstream remote state lookups"
  value       = "eks-platform-lab-tfstate-${data.aws_caller_identity.current.account_id}"
}

output "documents_bucket_name" {
  description = "S3 bucket holding uploaded documents"
  value       = module.data.documents_bucket_name
}

output "jobs_queue_url" {
  description = "URL of the jobs queue"
  value       = module.data.jobs_queue_url
}

output "jobs_queue_name" {
  description = "Name of the jobs queue, used by KEDA"
  value       = module.data.jobs_queue_name
}

output "database_secret_name" {
  description = "Secrets Manager secret name, referenced by External Secrets"
  value       = module.data.database_secret_name
}

output "database_identifier" {
  description = "RDS identifier, for stop and start"
  value       = module.data.database_identifier
}

output "ecr_repository_urls" {
  description = "ECR repository URIs keyed by service name"
  value       = module.data.ecr_repository_urls
}

output "workload_namespace" {
  description = "Namespace the application workloads run in"
  value       = var.workload_namespace
}