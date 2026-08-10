locals {
  cluster_name = "${var.project_name}-${var.environment}"
}

module "network" {
  source = "../../../modules/network"

  project_name = var.project_name
  cluster_name = local.cluster_name
  aws_region   = var.aws_region
}

module "cluster" {
  source = "../../../modules/cluster"

  project_name       = var.project_name
  cluster_name       = local.cluster_name
  private_subnet_ids = module.network.private_subnet_ids

  admin_access_principals = var.admin_access_principals
}