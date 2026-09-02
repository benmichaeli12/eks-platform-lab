variable "project_name" {
  description = "Name prefix applied to all resources"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC the database lives in"
  type        = string
}

variable "isolated_subnet_ids" {
  description = "Subnets with no internet route, where the database runs"
  type        = list(string)
}

variable "cluster_security_group_id" {
  description = "EKS cluster security group, allowed to reach the database"
  type        = string
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t4g.micro"
}

variable "db_allocated_storage" {
  description = "Storage in GB. RDS minimum is 20."
  type        = number
  default     = 20
}

variable "db_engine_version" {
  description = "PostgreSQL major version"
  type        = string
  default     = "16"
}

variable "queue_visibility_timeout" {
  description = "Seconds a message is hidden after a worker receives it. Must exceed processing time."
  type        = number
  default     = 300
}

variable "queue_max_receive_count" {
  description = "Delivery attempts before a message moves to the dead letter queue"
  type        = number
  default     = 3
}