# AWS itself

variable "aws_region" {
  description = "AWS region, for example `eu-west-2` = London"
}
variable "aws_profile" {
  description = "AWS cli profile, for example `default`"
}

# VPC variables

variable "vpc_name" {
  description = "Name of the VPC"
}

# Cluster variables

variable "cluster_name" {
  description = "Name of the cluster"
}
variable "kubernetes_version" {
  description = "Kubernetes master version"
}
variable "endpoint_private_access" {
  type        = bool
  description = "Choose wether the API endpoint is enabled for public access"
}
variable "endpoint_public_access" {
  type        = bool
  description = "Choose wether the API endpoint is enabled for private access, inside the VPC"
}

variable "logs_retention_in_days" {
  type        = number
  description = "Number of days you want to retain log events. Values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, and 3653."
}

# Node group variables

variable "node_group_name" {
  description = "Name of the node group"
}
variable "node_group_instance_types" {
  type        = list
  description = "Node group instance types"
}
variable "node_group_desired_size" {
  description = "Node group desired size"
}
variable "node_group_max_size" {
  description = "Node group maximum size"
}
variable "node_group_min_size" {
  description = "Node group minimum size"
}
variable "node_group_release_version" {
  description = "Node group release version"
}

#

variable "metrics_server_version" {
  description = "metrics-server version"
}

variable "nginx_ingress_controller_version" {
  description = "Nginx-Ingress-Controller version"
}

