output "ingest_api_role_arn" {
  description = "Role assumed by ingest-api pods"
  value       = aws_iam_role.ingest_api.arn
}

output "metadata_worker_role_arn" {
  description = "Role assumed by metadata-worker pods"
  value       = aws_iam_role.metadata_worker.arn
}

output "external_secrets_role_arn" {
  description = "Role assumed by the External Secrets Operator"
  value       = aws_iam_role.external_secrets.arn
}

output "keda_role_arn" {
  description = "Role assumed by the KEDA operator"
  value       = aws_iam_role.keda.arn
}