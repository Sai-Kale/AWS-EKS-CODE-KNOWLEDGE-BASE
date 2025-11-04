locals {
  default_cluster_proportional_autoscaler_config = {
    name             = "cluster-proportional-autoscaler"
    chart            = "cluster-proportional-autoscaler"
    repository       = "https://kubernetes-sigs.github.io/cluster-proportional-autoscaler"
    version          = var.cluster_proportional_autoscaler_chart_version
    namespace        = "kube-system"
    create_namespace = false
    timeout          = 1200
    description      = "Cluster Proportional Autoscaler Helm Chart"
    values = concat(
      [
        templatefile("${path.module}/values/cluster-proportional-autoscaler.yaml", {
          operating_system = "linux"
        })
      ],
      [
        yamlencode(lookup(var.override_values, "cluster-proportional-autoscaler", tomap({})))
      ]
    )
  }

  merged_cluster_proportional_autoscaler_config = var.cluster_proportional_autoscaler_config == null ? local.default_cluster_proportional_autoscaler_config : merge(local.default_cluster_proportional_autoscaler_config, var.cluster_proportional_autoscaler_config)
}

resource "helm_release" "cluster_proportional_autoscaler" {
  count            = var.enable_cluster_proportional_autoscaler ? 1 : 0
  name             = local.merged_cluster_proportional_autoscaler_config.name
  repository       = local.merged_cluster_proportional_autoscaler_config.repository
  chart            = local.merged_cluster_proportional_autoscaler_config.chart
  version          = local.merged_cluster_proportional_autoscaler_config.version
  namespace        = local.merged_cluster_proportional_autoscaler_config.namespace
  create_namespace = local.merged_cluster_proportional_autoscaler_config.create_namespace
  timeout          = local.merged_cluster_proportional_autoscaler_config.timeout
  description      = local.merged_cluster_proportional_autoscaler_config.description
  values           = local.merged_cluster_proportional_autoscaler_config.values
}


