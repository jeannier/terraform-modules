
# two "hello world" apps are returning "Version: 1.0.0" or "Version: 2.0.0"
# cf https://github.com/GoogleCloudPlatform/kubernetes-engine-samples/tree/master/hello-app

# configuration for ports and labels

locals {
  container_port = 8080
  elb_port       = 80
  labels_1 = {
    application = "hello-world-1"
  }
  labels_2 = {
    application = "hello-world-2"
  }
}

# deployment + service for hello-app:1.0

resource "kubernetes_deployment" "hello-world-1" {
  metadata {
    name = "hello-world-1"
  }
  spec {
    selector {
      match_labels = local.labels_1
    }
    template {
      metadata {
        labels = local.labels_1
      }
      spec {
        container {
          image = "gcr.io/google-samples/hello-app:1.0"
          name  = "hello-app"
          port {
            container_port = local.container_port
          }
        }
      }
    }
  }
  depends_on = [
    aws_eks_cluster.eks_cluster
  ]
}

resource "kubernetes_service" "hello-world-1" {
  metadata {
    name = "hello-world-1"
  }
  spec {
    selector = local.labels_1
    port {
      port        = local.elb_port
      target_port = local.container_port
    }
    type = "LoadBalancer"
  }
  depends_on = [
    aws_eks_cluster.eks_cluster
  ]
}

# deployment + service for hello-app:2.0

resource "kubernetes_deployment" "hello-world-2" {
  metadata {
    name = "hello-world-2"
  }
  spec {
    selector {
      match_labels = local.labels_2
    }
    template {
      metadata {
        labels = local.labels_2
      }
      spec {
        container {
          image = "gcr.io/google-samples/hello-app:2.0"
          name  = "hello-app"
          port {
            container_port = local.container_port
          }
        }
      }
    }
  }
  depends_on = [
    aws_eks_cluster.eks_cluster
  ]
}

resource "kubernetes_service" "hello-world-2" {
  metadata {
    name = "hello-world-2"
  }
  spec {
    selector = local.labels_2
    port {
      port        = local.elb_port
      target_port = local.container_port
    }
    type = "LoadBalancer"
  }
  depends_on = [
    aws_eks_cluster.eks_cluster
  ]
}

# ingress being read by the nginx-ingress-controller,
# and creating two paths :
# http://elb-url/1 --> hello-app:1.0 -> "Version: 1.0.0"
# http://elb-url/2 --> hello-app:2.0 -> "Version: 2.0.0"

resource "kubernetes_ingress" "hello-world" {
  metadata {
    name = "hello-world"
  }
  spec {
    rule {
      http {
        path {
          path = "/1"
          backend {
            service_name = "hello-world-1"
            service_port = 8080
          }
        }
        path {
          path = "/2"
          backend {
            service_name = "hello-world-2"
            service_port = 8080
          }
        }
      }
    }
  }
  depends_on = [
    aws_eks_cluster.eks_cluster
  ]
}
