
# terraform version

terraform {
  required_version = "~> 0.12"
}

# providers versions

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
  version = "~> 2.55"
}

provider "local" {
  version = "~> 1.4"
}

provider "null" {
  version = "~>  2.1"
}

# specific config for kubernetes provider

data "aws_eks_cluster_auth" "eks_cluster_auth" {
  name = aws_eks_cluster.eks_cluster.name
}

provider "kubernetes" {
  host                   = aws_eks_cluster.eks_cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.eks_cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.eks_cluster_auth.token
  load_config_file       = false
  version                = "~> 1.11"
}
