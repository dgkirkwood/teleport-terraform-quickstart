# Cert manager will handle TLS certificates backed by Lets Encrypt
# Cert manager will use AKS workload identity to authenticate to Azure DNS
resource "helm_release" "cert-manager" {
  name = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart = "cert-manager"
  create_namespace = true
  namespace = "cert-manager"
  set {
    name = "installCRDs"
    value = "true"
  }
  set {
    name = "podLabels.azure\\.workload\\.identity/use"
    value = "true"
    type = "string"
  }
  set {
    name = "serviceAccount.labels.azure\\.workload\\.identity/use"
    value = "true"
    type = "string"
  }
}

resource "kubectl_manifest" "cert-manager-issuer" {
  depends_on = [ helm_release.cert-manager ]
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-production
spec:
  acme:
    # The ACME server URL
    server: https://acme-v02.api.letsencrypt.org/directory
    # Email address used for ACME registration
    email: ${var.email_address}
    # Name of a secret used to store the ACME account private key
    privateKeySecretRef:
      name: letsencrypt-production
    solvers:
    - dns01:
        azureDNS:
          resourceGroupName: ${data.azurerm_resource_group.dnszone.name}
          subscriptionID: ${data.azurerm_subscription.current.subscription_id}
          hostedZoneName: ${var.dns_zone}
          environment: AzurePublicCloud
          managedIdentity:
            clientID: ${azurerm_user_assigned_identity.certmanager.client_id}
  YAML
}

