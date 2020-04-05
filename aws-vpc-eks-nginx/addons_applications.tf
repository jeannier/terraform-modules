
# configuration for our applications

locals {
  container_port = 8080
  elb_port       = 80
  applications = {
    "hello-app-1" = {
      "labels" = { application = "hello-app-1" }
      "image"  = "gcr.io/google-samples/hello-app:1.0"
      "path"   = "/helloapp1"
    },
    "hello-app-2" = {
      "labels" = { application = "hello-app-2" }
      "image"  = "gcr.io/google-samples/hello-app:2.0"
      "path"   = "/helloapp2"
    },
    "hello-node" = {
      "labels" = { application = "hello-node" }
      "image"  = "gcr.io/hello-minikube-zero-install/hello-node"
      "path"   = "/hellonode"
    },
    "hello-kub" = {
      "labels" = { application = "hello-kub" }
      "image"  = "paulbouwer/hello-kubernetes:1.7" # TODO : needs a "rewrite-target"
      "path"   = "/hellokub"
    },
  }
}

# deployment for the applications

resource "kubernetes_deployment" "deployment_apps" {

  for_each = local.applications

  metadata {
    name = each.key
  }
  spec {
    selector {
      match_labels = each.value.labels
    }
    template {
      metadata {
        labels = each.value.labels
      }
      spec {
        container {
          image = each.value.image
          name  = each.key
          port {
            container_port = local.container_port
          }
        }
      }
    }
  }

  # deployments can't complete without the workers nodes
  depends_on = [
    aws_eks_node_group.eks_node_group_01,
    aws_eks_node_group.eks_node_group_02
  ]

  # to allow the horizontal pod autoscaler to make changes to the number of replicas,
  # without Terraform interfering
  lifecycle {
    ignore_changes = [
      spec[0].replicas
    ]
  }
}

# service for the applications

resource "kubernetes_service" "service_apps" {

  for_each = local.applications

  metadata {
    name = each.key
  }
  spec {
    selector = each.value.labels
    port {
      port        = local.elb_port
      target_port = local.container_port
    }
    # type = "LoadBalancer"
  }
}

# the ingress is being read by the nginx-ingress-controller,
# and creating paths like :
# http://elb-url/helloapp1 --> hello-app:1.0 -> "Version: 1.0.0"
# http://elb-url/helloapp2 --> hello-app:2.0 -> "Version: 2.0.0"

resource "kubernetes_ingress" "ingress_apps" {
  metadata {
    name = "hello-world"
  }
  spec {
    rule {
      http {

        dynamic "path" {
          for_each = local.applications
          content {

            path = path.value.path
            backend {
              service_name = path.key
              service_port = local.container_port
            }

          }
        }

      }
    }
  }
}

# horizontal pod autoscalers for the applications
# we can scale between 1 and 10 replicas per deployment

resource "kubernetes_horizontal_pod_autoscaler" "horizontal_pod_autoscaler_apps" {

  for_each = local.applications

  metadata {
    name = each.key
  }
  spec {
    min_replicas                      = 1
    max_replicas                      = 100
    target_cpu_utilization_percentage = 80

    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = each.key
    }
  }
}
