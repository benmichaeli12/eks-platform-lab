output "documents_bucket_name" {
  description = "S3 bucket holding uploaded documents"
  value       = aws_s3_bucket.documents.id
}

output "documents_bucket_arn" {
  description = "ARN of the documents bucket"
  value       = aws_s3_bucket.documents.arn
}

output "jobs_queue_url" {
  description = "URL of the jobs queue, used by the SDK and by KEDA"
  value       = aws_sqs_queue.jobs.url
}

output "jobs_queue_arn" {
  description = "ARN of the jobs queue"
  value       = aws_sqs_queue.jobs.arn
}

output "jobs_queue_name" {
  description = "Name of the jobs queue"
  value       = aws_sqs_queue.jobs.name
}

output "jobs_dlq_url" {
  description = "URL of the dead letter queue"
  value       = aws_sqs_queue.jobs_dlq.url
}

output "database_secret_arn" {
  description = "Secrets Manager secret holding database credentials"
  value       = aws_secretsmanager_secret.database.arn
}

output "database_secret_name" {
  description = "Name of the database secret, referenced by External Secrets"
  value       = aws_secretsmanager_secret.database.name
}

output "database_endpoint" {
  description = "PostgreSQL endpoint, host and port"
  value       = aws_db_instance.main.endpoint
}

output "database_identifier" {
  description = "RDS instance identifier, for stop and start commands"
  value       = aws_db_instance.main.identifier
}

output "ecr_repository_urls" {
  description = "ECR repository URIs keyed by service name"
  value       = { for k, repo in aws_ecr_repository.services : k => repo.repository_url }
}