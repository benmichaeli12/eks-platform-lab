variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name prefix, used to locate the platform state"
  type        = string
  default     = "eks-platform-lab"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "state_bucket" {
  description = "Bucket holding the platform root's Terraform state"
  type        = string
}

variable "argocd_chart_version" {
  description = "Version of the argo-cd Helm chart"
  type        = string
  default     = "7.8.2"
}

variable "gitops_repo_url" {
  description = "HTTPS URL of the repository Argo CD watches"
  type        = string
}

variable "gitops_target_revision" {
  description = "Branch or tag Argo CD tracks"
  type        = string
  default     = "main"
}