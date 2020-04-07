
# deployment for the applications

resource "kubernetes_deployment" "deployment_apps" {

  for_each = var.applications

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
            container_port = each.value.container_port
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

  for_each = var.applications

  metadata {
    name = each.key
  }
  spec {
    selector = each.value.labels
    port {
      port        = var.elb_port
      target_port = each.value.container_port
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
          for_each = var.applications
          content {

            path = path.value.path
            backend {
              service_name = path.key
              service_port = path.value.container_port
            }

          }
        }

      }
    }
  }
}

# horizontal pod autoscalers for the applications
# we can scale automatically the numbers of replicas per deployment

resource "kubernetes_horizontal_pod_autoscaler" "horizontal_pod_autoscaler_apps" {

  for_each = var.applications

  metadata {
    name = each.key
  }
  spec {
    min_replicas                      = var.horizontal_pod_autoscaler_min_replicas
    max_replicas                      = var.horizontal_pod_autoscaler_max_replicas
    target_cpu_utilization_percentage = var.horizontal_pod_autoscaler_target_cpu

    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = each.key
    }
  }
}
