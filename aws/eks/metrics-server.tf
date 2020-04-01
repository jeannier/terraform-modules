
resource "null_resource" "apply_metrics_server" {

  provisioner "local-exec" {
    command = <<EOC
mkdir -p temp &&\
curl -Ls https://github.com/kubernetes-sigs/metrics-server/archive/v${var.metrics_server_version}.tar.gz -o metrics-server.tar.gz &&\
tar -C temp -xzf metrics-server.tar.gz metrics-server-${var.metrics_server_version}/deploy/1.8+/ --strip-components 3 &&\
kubectl apply -f temp &&\
rm -rf temp metrics-server.tar.gz
EOC
    environment = {
      KUBECONFIG = "kube.config"
    }
  }

  depends_on = [
    local_file.kubeconfig_file
  ]

}
