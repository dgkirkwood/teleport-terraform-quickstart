resource "helm_release" "teleport-cluster" {
  depends_on = [ azurerm_postgresql_flexible_server.teleport ]
  name = "teleport"
  repository = "https://charts.releases.teleport.dev"
  chart = "teleport-cluster"
  namespace = "teleport-cluster"
  create_namespace = true
  version = var.teleport_version
  set {
    name = "clusterName"
    value = "${var.cluster_hostname}.${var.dns_zone}"
  }
  set {
    name = "chartMode"
    value = "azure"
  }
  set {
    name = "azure.databaseHost"
    value = azurerm_postgresql_flexible_server.teleport.fqdn
  }
  set {
    name = "azure.databaseUser"
    value = "teleport-id"
  }
  set {
    name = "azure.sessionRecordingStorageAccount"
    value = azurerm_storage_account.teleport.primary_blob_host
  }
  set {
    name = "azure.auditLogMirrorOnStdout"
    value = "false"
  }
  set {
    name = "azure.clientID"
    value = azurerm_user_assigned_identity.teleport.client_id
  }
  set {
    name = "highAvailability.replicaCount"
    value = "2"
  }
  set {
    name = "highAvailability.certManager.enabled"
    value = "true"
  }
   set {
    name = "highAvailability.certManager.issuerName"
    value = "letsencrypt-production"
  } 
   set {
    name = "highAvailability.certManager.issuerKind"
    value = "ClusterIssuer"
  } 
  set {
    name = "podSecurityPolicy.enabled"
    value = "false"
  }
  set {
    name = "image"
    value = "public.ecr.aws/gravitational/teleport-distroless-debug"
  }
  set {
    name = "log.level"
    value = "DEBUG"
  }
}