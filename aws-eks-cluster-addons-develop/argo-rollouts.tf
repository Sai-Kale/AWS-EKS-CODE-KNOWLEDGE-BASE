locals {
  default_argo_rollouts_config = {
    name             = "argo-rollouts"
    chart            = "argo-rollouts"
    version          = var.argo_rollouts_chart_version
    namespace        = var.argo_rollouts_install_namespace
    create_namespace = true
    timeout          = 1200
    values = concat(
      [
        templatefile("${path.module}/values/argo.yaml", {})
      ],
      [
        yamlencode(lookup(var.override_values, "argo-rollouts", tomap({})))
      ]
    )
  }

  merged_argo_rollouts_config = var.argo_rollouts_helm_config == null ? local.default_argo_rollouts_config : merge(local.default_argo_rollouts_config, var.argo_rollouts_helm_config)
}

resource "helm_release" "argo_rollouts" {
  count             = var.enable_argo_rollouts ? 1 : 0
  name              = local.merged_argo_rollouts_config.name
  repository        = "https://argoproj.github.io/argo-helm"
  chart             = local.merged_argo_rollouts_config.chart
  version           = local.merged_argo_rollouts_config.version
  namespace         = local.merged_argo_rollouts_config.namespace
  create_namespace  = local.merged_argo_rollouts_config.create_namespace
  timeout           = local.merged_argo_rollouts_config.timeout
  values            = local.merged_argo_rollouts_config.values
}