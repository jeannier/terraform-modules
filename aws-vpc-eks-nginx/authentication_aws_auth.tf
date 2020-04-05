
# the aws-auth configmap needs to be deleted before being managed by Terraform
# cf https://github.com/terraform-aws-modules/terraform-aws-eks/issues/699
# and https://github.com/terraform-providers/terraform-provider-kubernetes/issues/719

resource "null_resource" "delete_config_map_aws_auth" {
  provisioner "local-exec" {
    command = "kubectl -n kube-system delete configmap aws-auth"
    environment = {
      KUBECONFIG = "kube.config"
    }
  }

  # aws-auth is getting created a few minutes after the end of the creation of the cluster,
  # so it's best to wait for the cluster+node groups to be created before attempting a deletion
  depends_on = [
    aws_eks_node_group.eks_node_group_01,
    aws_eks_node_group.eks_node_group_02
  ]
}


resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode([
      {
        rolearn  = aws_iam_role.iam_role_workers.arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups = [
          "system:bootstrappers",
          "system:nodes"
        ]
      }
    ])
    mapUsers = yamlencode([
      {
        userarn  = aws_iam_user.administrator.arn
        username = aws_iam_user.administrator.name
        groups   = ["system:masters"]
      },
      {
        userarn  = aws_iam_user.readonly.arn
        username = aws_iam_user.readonly.name
        groups   = ["read-only"]
      }
    ])
  }

  # aws-auth needs to be deleted first
  depends_on = [
    null_resource.delete_config_map_aws_auth
  ]
}
