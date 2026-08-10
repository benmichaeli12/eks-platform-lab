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