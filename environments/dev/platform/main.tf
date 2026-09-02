data "aws_caller_identity" "current" {}

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

module "data" {
  source = "../../../modules/data"

  project_name              = var.project_name
  environment               = var.environment
  vpc_id                    = module.network.vpc_id
  isolated_subnet_ids       = module.network.isolated_subnet_ids
  cluster_security_group_id = module.cluster.cluster_security_group_id
}

module "workload_identity" {
  source = "../../../modules/workload-identity"

  cluster_name         = module.cluster.cluster_name
  namespace            = var.workload_namespace
  documents_bucket_arn = module.data.documents_bucket_arn
  jobs_queue_arn       = module.data.jobs_queue_arn
  database_secret_arn  = module.data.database_secret_arn
}