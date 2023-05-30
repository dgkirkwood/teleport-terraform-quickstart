resource "helm_release" "ahoy" {
  name = "ahoy-app"
  repository = "https://helm.github.io/examples"
  chart = "hello-world"
}

resource "helm_release" "jenkins" {
  name = "apache"
  repository = "https://charts.bitnami.com/bitnami"
  chart = "apache"
}

resource "helm_release" "prometheus" {
  name = "grafana"
  repository = "https://charts.bitnami.com/bitnami"
  chart = "grafana"
}