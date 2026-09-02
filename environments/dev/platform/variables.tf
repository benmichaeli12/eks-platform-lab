variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name prefix applied to all resources"
  type        = string
  default     = "eks-platform-lab"
}

variable "environment" {
  description = "Environment name, used in tags and resource names"
  type        = string
  default     = "dev"
}

variable "admin_access_principals" {
  description = "IAM role or user ARNs granted cluster-admin. Add the CI role here."
  type        = list(string)
  default     = []
}

variable "workload_namespace" {
  description = "Kubernetes namespace the application workloads run in"
  type        = string
  default     = "documents"
}