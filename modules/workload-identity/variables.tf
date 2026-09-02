variable "cluster_name" {
  description = "EKS cluster the Pod Identity associations belong to"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace the application workloads run in"
  type        = string
  default     = "documents"
}

variable "documents_bucket_arn" {
  description = "ARN of the S3 bucket holding documents"
  type        = string
}

variable "jobs_queue_arn" {
  description = "ARN of the jobs queue"
  type        = string
}

variable "database_secret_arn" {
  description = "ARN of the Secrets Manager secret holding database credentials"
  type        = string
}