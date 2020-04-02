
# two "hello world" apps are returning "Version: 1.0.0" or "Version: 2.0.0"
# cf https://github.com/GoogleCloudPlatform/kubernetes-engine-samples/tree/master/hello-app

# configuration for ports and labels

locals {
  container_port = 8080
  elb_port       = 80
}

# deployment + service for hello-app:1.0

resource "kubernetes_deployment" "deployment_hello_world" {

  for_each = {
    "hello-world-1" = {
      "labels" = { application = "hello-world-1" },
      "image"  = "gcr.io/google-samples/hello-app:1.0"
    }
    "hello-world-2" = {
      "labels" = { application = "hello-world-2" },
      "image"  = "gcr.io/google-samples/hello-app:2.0"
    }
  }

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
  depends_on = [
    # deployments can't complete without the workers nodes
    aws_eks_node_group.eks_node_group
  ]
}

resource "kubernetes_service" "service_hello_world" {

  for_each = {
    "hello-world-1" = { application = "hello-world-1" }
    "hello-world-2" = { application = "hello-world-2" }
  }

  metadata {
    name = each.key
  }
  spec {
    selector = each.value
    port {
      port        = local.elb_port
      target_port = local.container_port
    }
    type = "LoadBalancer"
  }
}

# ingress being read by the nginx-ingress-controller,
# and creating two paths :
# http://elb-url/1 --> hello-app:1.0 -> "Version: 1.0.0"
# http://elb-url/2 --> hello-app:2.0 -> "Version: 2.0.0"

resource "kubernetes_ingress" "ingress_hello_world" {
  metadata {
    name = "hello-world"
  }
  spec {
    rule {
      http {

        dynamic "path" {
          for_each = ["1", "2"]
          content {

            path = "/${path.value}"

            backend {
              service_name = "hello-world-${path.value}"
              service_port = local.container_port
            }
          }
        }
      }
    }
  }
}

