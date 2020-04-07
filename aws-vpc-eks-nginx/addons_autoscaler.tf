# conversion done with https://github.com/sl1pm4t/k2tf (with --tf12format)
# from https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml
# and the deployment annotations + command + image url was tweaked for purpose
# automount_service_account_token was also added

resource "kubernetes_service_account" "cluster_autoscaler" {
  metadata {
    name      = "cluster-autoscaler"
    namespace = "kube-system"
    labels    = { k8s-addon = "cluster-autoscaler.addons.k8s.io", k8s-app = "cluster-autoscaler" }
  }
}

resource "kubernetes_cluster_role" "cluster_autoscaler" {
  metadata {
    name   = "cluster-autoscaler"
    labels = { k8s-addon = "cluster-autoscaler.addons.k8s.io", k8s-app = "cluster-autoscaler" }
  }
  rule {
    verbs      = ["create", "patch"]
    api_groups = [""]
    resources  = ["events", "endpoints"]
  }
  rule {
    verbs      = ["create"]
    api_groups = [""]
    resources  = ["pods/eviction"]
  }
  rule {
    verbs      = ["update"]
    api_groups = [""]
    resources  = ["pods/status"]
  }
  rule {
    verbs          = ["get", "update"]
    api_groups     = [""]
    resources      = ["endpoints"]
    resource_names = ["cluster-autoscaler"]
  }
  rule {
    verbs      = ["watch", "list", "get", "update"]
    api_groups = [""]
    resources  = ["nodes"]
  }
  rule {
    verbs      = ["watch", "list", "get"]
    api_groups = [""]
    resources  = ["pods", "services", "replicationcontrollers", "persistentvolumeclaims", "persistentvolumes"]
  }
  rule {
    verbs      = ["watch", "list", "get"]
    api_groups = ["extensions"]
    resources  = ["replicasets", "daemonsets"]
  }
  rule {
    verbs      = ["watch", "list"]
    api_groups = ["policy"]
    resources  = ["poddisruptionbudgets"]
  }
  rule {
    verbs      = ["watch", "list", "get"]
    api_groups = ["apps"]
    resources  = ["statefulsets", "replicasets", "daemonsets"]
  }
  rule {
    verbs      = ["watch", "list", "get"]
    api_groups = ["storage.k8s.io"]
    resources  = ["storageclasses", "csinodes"]
  }
  rule {
    verbs      = ["get", "list", "watch", "patch"]
    api_groups = ["batch", "extensions"]
    resources  = ["jobs"]
  }
  rule {
    verbs      = ["create"]
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
  }
  rule {
    verbs          = ["get", "update"]
    api_groups     = ["coordination.k8s.io"]
    resources      = ["leases"]
    resource_names = ["cluster-autoscaler"]
  }
}

resource "kubernetes_role" "cluster_autoscaler" {
  metadata {
    name      = "cluster-autoscaler"
    namespace = "kube-system"
    labels    = { k8s-addon = "cluster-autoscaler.addons.k8s.io", k8s-app = "cluster-autoscaler" }
  }
  rule {
    verbs      = ["create", "list", "watch"]
    api_groups = [""]
    resources  = ["configmaps"]
  }
  rule {
    verbs          = ["delete", "get", "update", "watch"]
    api_groups     = [""]
    resources      = ["configmaps"]
    resource_names = ["cluster-autoscaler-status", "cluster-autoscaler-priority-expander"]
  }
}

resource "kubernetes_cluster_role_binding" "cluster_autoscaler" {
  metadata {
    name   = "cluster-autoscaler"
    labels = { k8s-addon = "cluster-autoscaler.addons.k8s.io", k8s-app = "cluster-autoscaler" }
  }
  subject {
    kind      = "ServiceAccount"
    name      = "cluster-autoscaler"
    namespace = "kube-system"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-autoscaler"
  }
}

resource "kubernetes_role_binding" "cluster_autoscaler" {
  metadata {
    name      = "cluster-autoscaler"
    namespace = "kube-system"
    labels    = { k8s-addon = "cluster-autoscaler.addons.k8s.io", k8s-app = "cluster-autoscaler" }
  }
  subject {
    kind      = "ServiceAccount"
    name      = "cluster-autoscaler"
    namespace = "kube-system"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "cluster-autoscaler"
  }
}

resource "kubernetes_deployment" "cluster_autoscaler" {
  metadata {
    name      = "cluster-autoscaler"
    namespace = "kube-system"
    labels    = { app = "cluster-autoscaler" }
  }
  spec {
    replicas = 1
    selector {
      match_labels = { app = "cluster-autoscaler" }
    }
    template {
      metadata {
        labels      = { app = "cluster-autoscaler" }
        annotations = { "prometheus.io/port" = "8085", "prometheus.io/scrape" = "true" }
      }
      spec {

        # IMPORTANT - it's not set in aws/examples/cluster-autoscaler-autodiscover.yaml
        # but if we don't specify here, it will be set to false, and the pod won't be
        # able to get a k8s token, and won't be able to communicate with the k8s API
        # https://github.com/terraform-providers/terraform-provider-kubernetes/issues/263
        automount_service_account_token = true

        volume {
          name = "ssl-certs"
          host_path {
            path = "/etc/ssl/certs/ca-bundle.crt"
          }
        }
        container {
          name  = "cluster-autoscaler"
          image = var.autoscaler_image
          command = [
            "./cluster-autoscaler",
            "--v=4",
            "--stderrthreshold=info",
            "--cloud-provider=aws",
            "--skip-nodes-with-local-storage=false",
            "--expander=least-waste",
            "--node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/${var.cluster_name}",
            "--balance-similar-node-groups",
            "--skip-nodes-with-system-pods=false",
          ]
          resources {
            limits {
              cpu    = "100m"
              memory = "300Mi"
            }
            requests {
              cpu    = "100m"
              memory = "300Mi"
            }
          }
          volume_mount {
            name       = "ssl-certs"
            read_only  = true
            mount_path = "/etc/ssl/certs/ca-certificates.crt"
          }
          image_pull_policy = "Always"
        }
        service_account_name = "cluster-autoscaler"
      }
    }
  }
}
