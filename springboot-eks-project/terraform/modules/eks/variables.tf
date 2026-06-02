variable "cluster_name"          { type = string }
variable "environment"           { type = string }
variable "vpc_id"                { type = string }
variable "private_subnet_ids"    { type = list(string) }
variable "kubernetes_version"    { type = string; default = "1.29" }
variable "node_instance_types"   { type = list(string); default = ["t3.medium"] }
variable "node_desired_size"     { type = number; default = 2 }
variable "node_min_size"         { type = number; default = 1 }
variable "node_max_size"         { type = number; default = 5 }
variable "node_capacity_type"    { type = string; default = "ON_DEMAND" }
variable "enable_public_endpoint" { type = bool; default = false }
variable "log_retention_days"    { type = number; default = 30 }
variable "ecr_repo_name"         { type = string; default = "springboot-app" }
variable "common_tags"           { type = map(string); default = {} }
