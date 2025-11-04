locals {
  default_telepresence_config = {
    name             = "traffic-manager"
    chart            = "datawire/telepresence"
    version          = var.telepresence_chart_version
    namespace        = var.telepresence_install_namespace
    create_namespace = false
    timeout          = 1200
    values = concat(
      [
        templatefile("${path.module}/values/telepresence.yaml", {})
      ],
      [
        yamlencode(lookup(var.override_values, "telepresence", tomap({})))
      ]
    )
  }

  merged_telepresence_config = var.telepresence_helm_config == null ? local.default_telepresence_config : merge(local.default_telepresence_config, var.telepresence_helm_config)
}

resource "helm_release" "telepresence" {
  count             = var.enable_telepresence ? 1 : 0
  name              = local.merged_telepresence_config.name
  repository        = "https://app.getambassador.io"
  chart             = local.merged_telepresence_config.chart
  version           = local.merged_telepresence_config.version
  namespace         = local.merged_telepresence_config.namespace
  create_namespace  = local.merged_telepresence_config.create_namespace
  timeout           = local.merged_telepresence_config.timeout
  values            = local.merged_telepresence_config.values
}
