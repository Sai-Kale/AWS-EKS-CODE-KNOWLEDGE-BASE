resource "helm_release" "falcon-image-analyzer" {
  chart      = "falcon-image-analyzer"
  name       = "falcon-image-analyzer"
  namespace  = "falcon-system"
  version    = var.falcon_iar_chart_version
  repository = "https://artifactory.spectrumflow.net/artifactory/jfrog-charter-com-infosec-helm-virtual"

  repository_username = local.artifactory_username
  repository_password = local.artifactory_password

  values = [
    templatefile("${path.module}/addons/values/falcon-image-analyzer.yaml", {
      falcon_cid           = var.falcon_cid
      cluster_name         = module.eks.cluster_arn
      client_id            = var.falcon_client
      client_secret        = var.falcon_secret
      falcon_proxy_url     = var.falcon_proxy_url
      falcon_iar_image_tag = var.falcon_iar_image_tag
    })
  ]
  depends_on = [kubernetes_namespace.addon_namespaces, kubernetes_secret_v1.docker_registry_secret]
}

resource "helm_release" "kac" {
  chart      = "falcon-kac"
  name       = "falcon-kac"
  namespace  = "falcon-system"
  version    = var.falcon_kac_chart_version
  repository = "https://artifactory.spectrumflow.net/artifactory/jfrog-charter-com-infosec-helm-virtual"

  repository_username = local.artifactory_username
  repository_password = local.artifactory_password

  values = [
    templatefile("${path.module}/addons/values/falcon-kac.yaml", {
      falcon_cid           = var.falcon_cid
      falcon_kac_image_tag = var.falcon_kac_image_tag
    })
  ]
  depends_on = [helm_release.falcon-image-analyzer]
}
