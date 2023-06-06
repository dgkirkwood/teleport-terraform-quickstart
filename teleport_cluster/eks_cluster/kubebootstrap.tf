
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

resource "kubectl_manifest" "cert-manager-issuer" {
  depends_on = [ helm_release.cert-manager ]
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: letsencrypt-prod
  namespace: default
spec:
  acme:
    # The ACME server URL
    server: https://acme-v02.api.letsencrypt.org/directory
    # Email address used for ACME registration
    email: ${var.email_address}
    # Name of a secret used to store the ACME account private key
    privateKeySecretRef:
      name: letsencrypt-prod
    # Enable the HTTP-01 challenge provider
    solvers:
      - http01:
          ingress:
            ingressClassName: nginx
  YAML
}

# resource "kubernetes_manifest" "cert-manager-issuer" {
#   depends_on = [ helm_release.cert-manager ]
#   manifest = {
#     apiVersion = "cert-manager.io/v1"
#     kind = "Issuer"
#     metadata = {
#       name = "letsencrypt-prod"
#       namespace = "default"
#     }
#     spec = {
#       acme = {
#         server = "https://acme-v02.api.letsencrypt.org/directory"
#         email = var.email_address
#         privateKeySecretRef = {
#           name = "letsencrypt-prod"
#         }
#         solvers = [
#           {
#             http01 = {
#               ingress = {
#                 ingressClassName = "nginx"
#               }
#             }
#           }
#         ]
#       }
#     }
#   }
# }