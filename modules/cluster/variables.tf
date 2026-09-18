variable "project_name" {
  description = "Name prefix applied to all resources"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "EKS control plane version. Check available versions before changing."
  type        = string
  default     = "1.35"
}

variable "private_subnet_ids" {
  description = "Subnets where nodes, pods, and control plane network interfaces live"
  type        = list(string)
}

variable "public_access_cidrs" {
  description = "CIDRs allowed to reach the public Kubernetes API endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "node_instance_types" {
  description = "Instance types the Spot node group may use. More types means better Spot availability."
  type        = list(string)
  default     = ["t3.medium", "t3a.medium", "t2.medium"]
}

variable "node_capacity_type" {
  description = "SPOT or ON_DEMAND. Spot is roughly 70 percent cheaper and can be reclaimed."
  type        = string
  default     = "SPOT"
}

variable "node_min_size" {
  description = "Minimum number of nodes"
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum number of nodes"
  type        = number
  default     = 4
}

variable "node_desired_size" {
  description = "Starting number of nodes"
  type        = number
  default     = 2
}

variable "enabled_log_types" {
  description = "Control plane log types sent to CloudWatch. Each one costs ingestion."
  type        = list(string)
  default     = ["api", "audit", "authenticator"]
}

variable "log_retention_days" {
  description = "Retention for control plane logs"
  type        = number
  default     = 7
}

variable "admin_access_principals" {
  description = "IAM role or user ARNs granted cluster-admin through EKS access entries"
  type        = list(string)
  default     = []
}

variable "aws_region" {
  description = "AWS region, used to construct ARNs"
  type        = string
}

variable "github_repository" {
  description = "OIDC subject repository in GitHub's ID-bearing form: owner@ownerID/repo@repoID"
  type        = string
}

variable "github_branch" {
  description = "Branch allowed to assume the CI roles"
  type        = string
  default     = "main"
}