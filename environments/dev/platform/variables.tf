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