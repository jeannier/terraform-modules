
# read-only clusterrole/clusterrolebinding is set using the 'kubernetes' provider

resource "kubernetes_cluster_role" "read-only" {
  metadata {
    name = "read-only"
  }
  # to read anything
  rule {
    api_groups = [""]
    resources  = ["*"]
    verbs      = ["get", "list", "watch"]
  }
  # to execute to pods
  rule {
    api_groups = [""]
    resources  = ["pods/exec"]
    verbs      = ["create"]
  }
}

resource "kubernetes_cluster_role_binding" "read-only" {
  metadata {
    name = "read-only"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "read-only"
  }
  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Group"
    # the read-only Group is the one listed in the aws-auth configmap
    name = "read-only"
  }
}

# getting the AWS account ID, to use in the configmap aws-auth

data "aws_caller_identity" "caller_identity" {}

# aws-auth configmap for EKS, with 2 new entries :
# - admin user, part of 'system:masters'
# - readonly user, part of 'readonly'
# it's created via local-exec as we can't overwrite the pre-existing configmap with the 'kubernetes' provider

locals {
  config_map_aws_auth = <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.iam_role_workers.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
      - system:bootstrappers
      - system:nodes
  mapUsers: |
    - userarn: arn:aws:iam::${data.aws_caller_identity.caller_identity.account_id}:user/${aws_iam_user.administrator.name}
      username: ${aws_iam_user.administrator.name}
      groups:
      - system:masters
    - userarn: arn:aws:iam::${data.aws_caller_identity.caller_identity.account_id}:user/${aws_iam_user.readonly.name}
      username: ${aws_iam_user.readonly.name}
      groups:
      - read-only
EOF
}

# writing down the aws-auth.yaml file

resource "local_file" "config_map_aws_auth_file" {
  content = local.config_map_aws_auth
  # setting the filename as a "dotfile" to hide it
  filename = ".aws-auth.yaml"
}

# a change to aws-auth.yaml will trigger 'kubectl apply'

resource "null_resource" "apply_config_map_aws_auth" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${local_file.config_map_aws_auth_file.filename}"
    environment = {
      KUBECONFIG = "kube.config"
    }
  }

  # the aws-auth.yaml file + the cluster itself + the kubeconfig must be created before the kubectl execution
  depends_on = [
    local_file.config_map_aws_auth_file,
    aws_eks_cluster.eks_cluster,
    local_file.kubeconfig_file
  ]

  # we only want to trigger kubectl if the file changed
  triggers = {
    template_sha1 = "${sha1(local.config_map_aws_auth)}"
  }

}
