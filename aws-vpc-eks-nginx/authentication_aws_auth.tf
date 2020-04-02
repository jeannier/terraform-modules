
# getting the AWS account ID, to use in the configmap aws-auth

data "aws_caller_identity" "caller_identity" {}

# aws-auth configmap for EKS, with 2 new entries :
# - admin user, part of 'system:masters'
# - readonly user, part of 'readonly'

# it's created via local-exec as we can't overwrite the pre-existing configmap with the 'kubernetes' provider
# cf https://github.com/terraform-aws-modules/terraform-aws-eks/issues/699
# and https://github.com/terraform-providers/terraform-provider-kubernetes/issues/719

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
    local_file.kubeconfig_file
  ]

  # we only want to trigger kubectl if the file changed
  triggers = {
    template_sha1 = "${sha1(local.config_map_aws_auth)}"
  }

}
