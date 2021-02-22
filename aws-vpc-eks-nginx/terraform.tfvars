
# providers
aws_region  = "eu-west-2"
aws_profile = "default"

# vpc
vpc_name = "eks-vpc"

# cluster
cluster_name            = "eks-alex"
kubernetes_version      = 1.17
endpoint_private_access = false
endpoint_public_access  = true
logs_retention_in_days  = 3

# node group (x2)
node_group_name            = "eks-alex"
node_group_instance_types  = ["t2.small"]
node_group_desired_size    = 1
node_group_max_size        = 5
node_group_min_size        = 1
node_group_release_version = "1.17.9-20200904"

# applications
metrics_server_version           = "0.3.6"
nginx_ingress_controller_version = "0.30.0"
autoscaler_image                 = "eu.gcr.io/k8s-artifacts-prod/autoscaling/cluster-autoscaler:v1.17.3"
elb_port                         = 80
applications = {
  hello-app-1 = {
    labels         = { application = "hello-app-1" }
    image          = "gcr.io/google-samples/hello-app:1.0"
    path           = "/helloapp1"
    container_port = 8080
  },
  hello-app-2 = {
    labels         = { application = "hello-app-2" }
    image          = "gcr.io/google-samples/hello-app:2.0"
    path           = "/helloapp2"
    container_port = 8080
  },
  hello-node = {
    labels         = { application = "hello-node" }
    image          = "gcr.io/hello-minikube-zero-install/hello-node"
    path           = "/hellonode"
    container_port = 8080
  },
  hello-kub = {
    labels         = { application = "hello-kub" }
    image          = "paulbouwer/hello-kubernetes:1.7"
    path           = "/hellokub"
    container_port = 8080
  }
}
horizontal_pod_autoscaler_min_replicas = 1
horizontal_pod_autoscaler_max_replicas = 100
horizontal_pod_autoscaler_target_cpu   = 80
