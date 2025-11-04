resource "helm_release" "metacontroller" {
  count      = var.enable_metacontroller ? 1 : 0
  name       = "metacontroller"
  repository = "https://artifactory.spectrumflow.net/artifactory/helm"
  chart      = "metacontroller-helm"
  version    = var.metacontroller_helm_version
  namespace  = "meta-controller"

  repository_username = local.artifactory_username
  repository_password = local.artifactory_password

  set = [
    {
      name  = "image.repository"
      value = "docker-artifactory.spectrumflow.net/docker/metacontroller/metacontroller"
    },
    {
      name  = "imagePullSecrets[0].name"
      value = "docker-artifactory"
    }
  ]

  depends_on = [kubernetes_namespace.addon_namespaces, kubernetes_secret_v1.docker_registry_secret]

}
