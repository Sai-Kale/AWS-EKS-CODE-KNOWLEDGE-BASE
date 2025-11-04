locals {
  default_node_local_dns_config = {
    name             = "node-local-dns"
    chart            = "node-local-dns"
    repository       = "https://lablabs.github.io/k8s-nodelocaldns-helm/"
    version          = var.node_local_dns_chart_version
    namespace        = "kube-system"
    create_namespace = false
    timeout          = 1200
    values = concat(
      [
       templatefile("${path.module}/values/nodelocaldns.yaml", {
          poller_interval_ms = var.poller_interval_ms
        })
      ],
      [
        yamlencode(lookup(var.override_values, "node_local_dns", tomap({})))
      ]
    )
  }

  merged_node_local_dns_helm_config = var.node_local_dns_helm_config == null ? local.default_node_local_dns_config : merge(local.default_node_local_dns_config, var.node_local_dns_helm_config)
}


resource "helm_release" "node_local_dns" {
  count             = var.enable_node_local_dns ? 1 : 0
  name              = local.merged_node_local_dns_helm_config.name
  repository        = local.merged_node_local_dns_helm_config.repository
  chart             = local.merged_node_local_dns_helm_config.chart
  version           = local.merged_node_local_dns_helm_config.version
  namespace         = local.merged_node_local_dns_helm_config.namespace
  create_namespace  = local.merged_node_local_dns_helm_config.create_namespace
  timeout           = local.merged_node_local_dns_helm_config.timeout
  values            = local.merged_node_local_dns_helm_config.values
}
