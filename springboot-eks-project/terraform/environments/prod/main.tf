terraform {
  required_version = ">= 1.7.0"

  backend "s3" {
    bucket         = "springboot-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }

  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "springboot-app"
      Environment = "prod"
      ManagedBy   = "terraform"
    }
  }
}

locals {
  cluster_name = "${var.project_name}-eks-${var.environment}"
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

module "vpc" {
  source       = "../../modules/vpc"
  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
  az_count     = 3
  cluster_name = local.cluster_name
  common_tags  = local.common_tags
}

module "eks" {
  source                 = "../../modules/eks"
  cluster_name           = local.cluster_name
  environment            = var.environment
  vpc_id                 = module.vpc.vpc_id
  private_subnet_ids     = module.vpc.private_subnet_ids
  kubernetes_version     = "1.29"
  node_instance_types    = ["t3.large"]
  node_desired_size      = 3
  node_min_size          = 2
  node_max_size          = 10
  node_capacity_type     = "ON_DEMAND"
  enable_public_endpoint = false
  ecr_repo_name          = "springboot-app"
  common_tags            = local.common_tags
}

output "cluster_name" { value = module.eks.cluster_name }
output "ecr_repo_url" { value = module.eks.ecr_repo_url }
output "vpc_id"       { value = module.vpc.vpc_id }
