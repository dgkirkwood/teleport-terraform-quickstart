resource "helm_release" "ahoy" {
  name = "ahoy-app"
  repository = "https://helm.github.io/examples"
  chart = "hello-world"
}

resource "helm_release" "jenkins" {
  name = "jenkins"
  repository = "https://charts.bitnami.com/bitnami"
  chart = "jenkins"
}

resource "helm_release" "prometheus" {
  name = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart = "prometheus"
}