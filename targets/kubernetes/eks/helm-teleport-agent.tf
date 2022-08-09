provider "helm" {
  kubernetes {
    host = data.aws_eks_cluster.cluster.endpoint
    token                  = data.aws_eks_cluster_auth.cluster.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  }
}

resource "helm_release" "teleportagent" {
  name = "teleportagent"
  repository = "https://charts.releases.teleport.dev"
  chart = "teleport-kube-agent"
  namespace = "teleport-agent"
  create_namespace = true
  set {
    name = "kubeClusterName"
    value = var.clustername
  }
  set {
    name = "proxyAddr"
    value = var.proxy_address
  }
  set {
    name = "authToken"
    value = var.auth_token
  }
  set {
    name = "labels.environment"
    value = var.label_environment
  }
  set {
    name = "labels.cloud"
    value = "aws"
  }
  set {
    name = "labels.region"
    value = var.region
  }
}