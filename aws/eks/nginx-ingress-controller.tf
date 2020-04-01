
resource "null_resource" "nginx_ingress_controller" {

  depends_on = [
    local_file.kubeconfig_file
  ]
  provisioner "local-exec" {
    command = "kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-${var.nginx_ingress_controller_version}/deploy/static/mandatory.yaml"
    environment = {
      KUBECONFIG = "kube.config"
    }
  }
  provisioner "local-exec" {
    command = "kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-${var.nginx_ingress_controller_version}/deploy/static/provider/aws/patch-configmap-l7.yaml"
    environment = {
      KUBECONFIG = "kube.config"
    }
  }
}

# inspired from
# https://github.com/kubernetes/ingress-nginx/blob/master/deploy/static/provider/aws/service-l7.yaml
# but without the SSL-related configuration

resource "kubernetes_service" "ingress-nginx" {
  metadata {
    name      = "ingress-nginx"
    namespace = "ingress-nginx"
    labels = {
      "app.kubernetes.io/name"    = "ingress-nginx"
      "app.kubernetes.io/part-of" = "ingress-nginx"
    }
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-backend-protocol" = "http"
    }
  }
  spec {
    selector = {
      "app.kubernetes.io/name"    = "ingress-nginx"
      "app.kubernetes.io/part-of" = "ingress-nginx"
    }
    port {
      name        = "http"
      port        = 80
      protocol    = "TCP"
      target_port = "http"
    }
    type = "LoadBalancer"
  }
}
