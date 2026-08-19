data "terraform_remote_state" "platform" {
  backend = "s3"

  config = {
    bucket = var.state_bucket
    key    = "platform/terraform.tfstate"
    region = var.aws_region
  }
}

data "aws_eks_cluster_auth" "cluster" {
  name = data.terraform_remote_state.platform.outputs.cluster_name
}

provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {
  host                   = data.terraform_remote_state.platform.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.platform.outputs.cluster_certificate_authority)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes = {
    host                   = data.terraform_remote_state.platform.outputs.cluster_endpoint
    cluster_ca_certificate = base64decode(data.terraform_remote_state.platform.outputs.cluster_certificate_authority)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}