provider "helm" {
  kubernetes {
    host = data.aws_eks_cluster.cluster.endpoint
    token                  = data.aws_eks_cluster_auth.cluster.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  }
}

resource "helm_release" "teleportagent" {
  for_each = var.cluster_flavours
  name = "teleportagent-${each.value.environment}"
  repository = "https://charts.releases.teleport.dev"
  chart = "teleport-kube-agent"
  namespace = "teleport-agent-${each.value.environment}"
  create_namespace = true
  version = var.teleport_version
  set {
    name = "kubeClusterName"
    value = each.value.clustername
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
    value = each.value.environment
  }
  set {
    name = "labels.cloud"
    value = "aws"
  }
  set {
    name = "labels.region"
    value = var.region
  }
  set {
    name = "labels.k8s-version"
    value = module.eks.cluster_version
  }
}