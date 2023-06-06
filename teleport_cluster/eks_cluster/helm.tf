provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
        api_version = "client.authentication.k8s.io/v1beta1"
        command     = "aws"
        args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}

resource "helm_release" "nginx" {
    repository = "https://kubernetes.github.io/ingress-nginx"
    chart = "ingress-nginx"
    create_namespace = false
    name = var.ingress_name
    
}

resource "helm_release" "cert-manager" {
  repository = "https://charts.jetstack.io"
  chart = "cert-manager"
  name = "cert-manager"
  create_namespace = false
  version = "v1.12.0"
  depends_on = [ kubernetes_cluster_role_binding.view ]
  set {
    name = "installCRDs"
    value = "true"
  }
}

resource "helm_release" "teleport" {
  repository = "https://charts.releases.teleport.dev"
  chart = "teleport-cluster"
  name=  "teleport-cluster"
  version = var.teleport_version
  create_namespace = false
  set {
    name = "clusterName"
    value = var.cluster_fqdn
  }
  set {
    name = "persistence.enabled"
    value = "false"
  }
  set {
    name = "proxyListenerMode"
    value = "multiplex"
  }
  set {
    name = "service.type"
    value = "ClusterIP"
  }
  depends_on = [ helm_release.nginx ]
}