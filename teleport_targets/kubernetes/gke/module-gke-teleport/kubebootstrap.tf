data "google_client_config" "default" {}


provider "kubernetes" {
  host = "https://${google_container_cluster.primary.endpoint}"

  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
}


resource "kubernetes_cluster_role_binding" "view" {
  metadata {
    name = "view"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "view"
  }
  subject {
    kind = "Group"
    name = "viewonly"
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_cluster_role_binding" "edit" {
  metadata {
    name = "edit"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "edit"
  }
  subject {
    kind = "Group"
    name = "edit"
    api_group = "rbac.authorization.k8s.io"
  }
}