provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
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

resource "kubernetes_ingress_v1" "teleport" {
  depends_on = [ helm_release.nginx ]
  metadata {
    name = "teleport"
    annotations = {
      "cert-manager.io/issuer" = "letsencrypt-prod"
      "nginx.ingress.kubernetes.io/backend-protocol" = "HTTPS"
    }
  }
  spec {
    ingress_class_name = "nginx"
    tls {
      hosts = [
        var.cluster_fqdn
      ]
      secret_name = "teleport-tls"
    }
    rule {
      host = var.cluster_fqdn
      http {
        path {
          path = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "teleport-cluster"
              port {
                number = 443
              }
            }
          }
        }
      }
    }

  }


  }

resource "kubernetes_manifest" "cert-manager-issuer" {
  depends_on = [ helm_release.cert-manager ]
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind = "Issuer"
    metadata = {
      name = "letsencrypt-prod"
      namespace = "default"
    }
    spec = {
      acme = {
        server = "https://acme-v02.api.letsencrypt.org/directory"
        email = var.email_address
        privateKeySecretRef = {
          name = "letsencrypt-prod"
        }
        solvers = [
          {
            http01 = {
              ingress = {
                ingressClassName = "nginx"
              }
            }
          }
        ]
      }
    }
  }
}