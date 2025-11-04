resource "helm_release" "fluentd" {
  count      = var.enable_otel ? 0 : 1
  chart      = "splunk-kubernetes-logging"
  name       = "splunk"
  version    = var.fluentd_version
  namespace  = "fluentd"
  repository = "https://artifactory.spectrumflow.net/artifactory/awsinfra-helm"

  repository_username = local.artifactory_username
  repository_password = local.artifactory_password

  values = [
    templatefile("${path.module}/addons/values/fluentd.yaml", {
      cluster_name = var.cluster_name
      splunk_index = var.splunk_index
      splunk_host  = var.splunk_host
      splunk_token = local.splunk_token
    }),
    yamlencode(try(var.fluentd_helm_values, {}))
  ]
  depends_on = [kubernetes_namespace.addon_namespaces, kubernetes_secret_v1.docker_registry_secret]
}

resource "helm_release" "otel" {
  count      = var.enable_otel ? 1 : 0
  chart      = "splunk-otel-collector"
  name       = "splunk-otel"
  version    = var.otel_version
  namespace  = "otel-splunk"
  repository = "https://signalfx.github.io/splunk-otel-collector-chart"


  values = [
    templatefile("${path.module}/addons/values/values-splunk-otel.yaml", {
      cluster_name       = var.cluster_name
      splunk_index       = var.splunk_index
      splunk_host        = var.splunk_host
      splunk_token       = local.splunk_token
      otel_app_namespace = var.otel_app_namespace
    })
  ]
  depends_on = [kubernetes_namespace.addon_namespaces, kubernetes_secret_v1.docker_registry_secret]
}

resource "helm_release" "datadog" {
  chart      = "datadog"
  name       = "datadog"
  version    = var.datadog_version
  namespace  = "datadog"
  repository = "https://artifactory.spectrumflow.net/artifactory/helm"

  repository_username = local.artifactory_username
  repository_password = local.artifactory_password

  values = [
    templatefile("${path.module}/addons/values/datadog.yaml", {
      cluster_name    = var.cluster_name
      datadog_app_key = try(local.datadog_app_key, "")      
      datadog_api_key = local.datadog_api_key
    }),
    yamlencode(try(var.datadog_helm_values, {}))
  ]
  depends_on = [kubernetes_namespace.addon_namespaces, kubernetes_secret_v1.docker_registry_secret]
}


# Cluster autoscaler moved to addons-cluster-autoscaler.tf for proper IRSA configuration

resource "helm_release" "metrics-server" {
  chart      = "metrics-server"
  name       = "metrics-server"
  namespace  = "metrics-server"
  version    = var.metric_server_version
  repository = "https://artifactory.spectrumflow.net/artifactory/helm"

  repository_username = local.artifactory_username
  repository_password = local.artifactory_password
  depends_on          = [kubernetes_namespace.addon_namespaces, kubernetes_secret_v1.docker_registry_secret]
}


resource "helm_release" "kube-state-metrics" {
  chart      = "kube-state-metrics"
  name       = "kube-state-metrics"
  repository = "https://prometheus-community.github.io/helm-charts"
  version    = "4.20.2"
  values     = [templatefile("${path.module}/addons/values/kube-state-metrics.yaml", {})]
  depends_on = [kubernetes_namespace.addon_namespaces, kubernetes_secret_v1.docker_registry_secret]
}


resource "helm_release" "cert-manager" {
  count      = var.enable_cert_manager == true ? 1 : 0
  chart      = "cert-manager"
  name       = "cert-manager"
  version    = var.cert_manager_version
  namespace  = "cert-manager"
  repository = "https://artifactory.spectrumflow.net/artifactory/specflow-mirrors"

  repository_username = local.artifactory_username
  repository_password = local.artifactory_password

  set = [
    {
      name  = "crds.enabled"
      value = "true"
    }
  ]
  depends_on = [kubernetes_namespace.addon_namespaces, kubernetes_secret_v1.docker_registry_secret]
}

resource "helm_release" "pod-reloader" {
  count      = var.enable_pod_reloader == true ? 1 : 0
  chart      = "reloader"
  name       = "reloader"
  version    = var.pod_reloader_version
  namespace  = "pod-reloader"
  repository = "https://artifactory.spectrumflow.net/artifactory/specflow-mirrors"

  repository_username = local.artifactory_username
  repository_password = local.artifactory_password

  values = [
    yamlencode(try(var.pod_reloader_helm_values, {}))
  ]

  depends_on = [kubernetes_namespace.addon_namespaces, kubernetes_secret_v1.docker_registry_secret]
}

resource "helm_release" "external-secrets" {
  count      = var.enable_external_secrets ? 1 : 0
  chart      = "external-secrets"
  name       = "external-secrets"
  namespace  = "external-secrets"
  version    = var.external_secrets_version
  repository = "https://artifactory.spectrumflow.net/artifactory/specflow-mirrors"

  repository_username = local.artifactory_username
  repository_password = local.artifactory_password

  depends_on = [kubernetes_namespace.addon_namespaces, kubernetes_secret_v1.docker_registry_secret]
}

resource "kubectl_manifest" "eni_config" {
  for_each = (var.enable_amazon_eks_vpc_cni_custom_networking && (length(var.eks_pod_subnets) > 0)) ? var.eks_pod_subnets : {}

  yaml_body = yamlencode({
    apiVersion = "crd.k8s.amazonaws.com/v1alpha1"
    kind       = "ENIConfig"
    metadata = {
      name = each.key
    }
    spec = {
      securityGroups = [
        module.eks.cluster_security_group_id,
        module.eks.node_security_group_id
      ]
      subnet = each.value
    }
  })
  depends_on = [module.eks.cluster_name]
}
