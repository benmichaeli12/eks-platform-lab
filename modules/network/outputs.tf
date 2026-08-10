output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC, for security group rules"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "Public subnet IDs, ordered by availability zone"
  value       = [for k in sort(keys(aws_subnet.public)) : aws_subnet.public[k].id]
}

output "private_subnet_ids" {
  description = "Private subnet IDs, ordered by availability zone"
  value       = [for k in sort(keys(aws_subnet.private)) : aws_subnet.private[k].id]
}

output "isolated_subnet_ids" {
  description = "Isolated subnet IDs, ordered by availability zone"
  value       = [for k in sort(keys(aws_subnet.isolated)) : aws_subnet.isolated[k].id]
}

output "nat_public_ips" {
  description = "Public IPs the private subnets egress from"
  value       = [for eip in aws_eip.nat : eip.public_ip]
}