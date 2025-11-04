resource "kubernetes_namespace" "addon_namespaces" {
  for_each = toset(local.all_addon_namespaces)

  metadata {
    name = each.key
  }
  depends_on = [module.eks]
}


resource "kubernetes_secret_v1" "docker_registry_secret" {
  for_each = toset(concat(local.all_addon_namespaces, ["kube-system"]))

  metadata {
    name      = "docker-artifactory"
    namespace = each.key
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "docker-artifactory.spectrumflow.net" = {
          "username" = local.artifactory_username
          "password" = local.artifactory_password
          "auth"     = base64encode("${local.artifactory_username}:${local.artifactory_password}")
        }
      }
    })
  }
  depends_on = [module.eks, kubernetes_namespace.addon_namespaces]
}
