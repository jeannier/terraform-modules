
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
