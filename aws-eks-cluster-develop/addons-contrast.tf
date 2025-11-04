resource "helm_release" "contrast-agent-operator" {
  count = var.enable_contrast_agent ? 1 : 0

  chart      = "contrast-agent-operator"
  name       = "contrast-agent-operator"
  version    = var.contrast_agent_operator_version
  repository = "https://contrastsecurity.dev/helm-charts"
  values = [
    templatefile("${path.module}/addons/values/contrast-agent-operator.yaml", {
      username = local.artifactory_username
      password = local.artifactory_password
    })
  ]
  depends_on = [module.eks]
}


resource "kubernetes_secret" "contrast-agent-secret" {
  count = var.enable_contrast_agent ? 1 : 0

  metadata {
    name      = "default-agent-connection-secret"
    namespace = "contrast-agent-operator"
  }
  data = {
    "apiKey"     = local.contrast_api_key
    "serviceKey" = local.contrast_service_key
    "userName"   = local.contrast_username
  }
  depends_on = [helm_release.contrast-agent-operator]
}

resource "kubectl_manifest" "default-agent-configuration" {
  count = var.enable_contrast_agent ? 1 : 0

  yaml_body = templatefile("${path.module}/addons/templates/contrast-agent-configuration.yaml", {
    environment = var.contrast_agent_environment
    name        = "default-agent-configuration"
    namespace   = "contrast-agent-operator"
  })
  depends_on = [helm_release.contrast-agent-operator]
}

resource "kubectl_manifest" "default-agent-connection" {
  count = var.enable_contrast_agent ? 1 : 0

  yaml_body = templatefile("${path.module}/addons/templates/contrast-agent-connection.yaml", {
    name        = "default-agent-connection"
    namespace   = "contrast-agent-operator"
    secret_name = kubernetes_secret.contrast-agent-secret[0].metadata[0].name
  })
  depends_on = [helm_release.contrast-agent-operator, kubernetes_secret.contrast-agent-secret]
}
