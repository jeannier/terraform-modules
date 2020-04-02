
# providers
aws_region  = "eu-west-2"
aws_profile = "default"

# vpc
vpc_name = "eks-vpc"

# cluster
cluster_name            = "eks-alex"
kubernetes_version      = 1.15
endpoint_private_access = false
endpoint_public_access  = true
logs_retention_in_days  = 3

# node group
node_group_name            = "eks-alex"
node_group_instance_types  = ["t2.small"]
node_group_desired_size    = 1
node_group_max_size        = 1
node_group_min_size        = 1
node_group_release_version = "1.15.10-20200228"

# applications
metrics_server_version           = "0.3.6"
nginx_ingress_controller_version = "0.30.0"
