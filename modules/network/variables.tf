variable "project_name" {
  description = "Name prefix applied to all resources"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name, used for Kubernetes subnet discovery tags"
  type        = string
}

variable "aws_region" {
  description = "AWS region, combined with the AZ suffix keys below"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "Public subnet CIDRs keyed by availability zone suffix. Load balancers and NAT."
  type        = map(string)
  default = {
    a = "10.0.0.0/24"
    b = "10.0.1.0/24"
  }
}

variable "private_subnets" {
  description = "Private subnet CIDRs keyed by AZ suffix. Nodes and pods — sized large for pod IPs."
  type        = map(string)
  default = {
    a = "10.0.16.0/20"
    b = "10.0.32.0/20"
  }
}

variable "isolated_subnets" {
  description = "Isolated subnet CIDRs keyed by AZ suffix. Databases, no route to the internet."
  type        = map(string)
  default = {
    a = "10.0.48.0/24"
    b = "10.0.49.0/24"
  }
}

variable "single_nat_gateway" {
  description = "Run one NAT gateway for all AZs instead of one per AZ. Cheaper, less available."
  type        = bool
  default     = true
}