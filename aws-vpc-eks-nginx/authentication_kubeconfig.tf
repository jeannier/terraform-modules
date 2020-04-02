data "aws_region" "current" {
}

locals {
  kubeconfig = <<EOF
apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.eks_cluster.endpoint}
    certificate-authority-data: ${aws_eks_cluster.eks_cluster.certificate_authority.0.data}
  name: "${var.cluster_name}"
contexts:
- context:
    cluster: "${var.cluster_name}"
    user: aws-get-token
  name: "${var.cluster_name}"
current-context: "${var.cluster_name}"
kind: Config
preferences: {}
users:
- name: aws-get-token
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      args:
      - --region
      - ${data.aws_region.current.name}
      - eks
      - get-token
      - --cluster-name
      - "${var.cluster_name}"
      command: aws
EOF
}

resource "local_file" "kubeconfig_file" {
  content  = local.kubeconfig
  filename = "kube.config"
}
