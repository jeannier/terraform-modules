
# installing metrics-server, to get resource usage data
# official repo : https://github.com/kubernetes-sigs/metrics-server
# doc from which I took inspiration from : https://docs.aws.amazon.com/eks/latest/userguide/metrics-server.html

resource "null_resource" "exec_metrics_server" {

  provisioner "local-exec" {

    command = <<EOC
mkdir -p $TEMP_DIR &&\
curl -Ls https://github.com/kubernetes-sigs/metrics-server/archive/v${var.metrics_server_version}.tar.gz --output - | tar  xvz -C $TEMP_DIR metrics-server-${var.metrics_server_version}/deploy/1.8+/ --strip-components 3 &&\
kubectl apply -f $TEMP_DIR &&\
rm -rf $TEMP_DIR
EOC

    environment = {
      KUBECONFIG = "kube.config"
      TEMP_DIR   = ".temp"
    }
  }

  depends_on = [
    local_file.kubeconfig_file
  ]

}
