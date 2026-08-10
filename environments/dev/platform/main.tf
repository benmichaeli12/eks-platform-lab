locals {
  cluster_name = "${var.project_name}-${var.environment}"
}

module "network" {
  source = "../../../modules/network"

  project_name = var.project_name
  cluster_name = local.cluster_name
  aws_region   = var.aws_region
}