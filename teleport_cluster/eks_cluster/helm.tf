provider "helm" {
  kubernetes {
    host = data.aws_eks_cluster.cluster.endpoint
    token                  = data.aws_eks_cluster_auth.cluster.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  }
}

resource "helm_release" "nginx" {
    repository = "https://kubernetes.github.io/ingress-nginx"
    chart = "ingress-nginx"
    create_namespace = false
    name = "nginx"
}

# resource "helm_release" "cert-manager" {
  
# }

resource "helm_release" "teleport" {
  repository = "https://charts.releases.teleport.dev"
  chart = "teleport-cluster"
  name=  "teleport"
  version = var.teleport_version
  create_namespace = false
  values = [
    file("k8sfiles/teleport-values.yaml")
  ]
}