resource "kubectl_manifest" "cluster_roles" {
  for_each = length(var.workload_namespaces) > 0 && var.enable_custom_rbac ? var.rbac_map_cluster_roles : {}

  yaml_body = yamlencode({
    apiVersion = "rbac.authorization.k8s.io/v1"
    kind       = "ClusterRole"
    metadata = {
      name = each.key
    }
    rules = [
      {
        apiGroups = each.value.apiGroups
        resources = each.value.resources
        verbs     = each.value.verbs
      }
    ]
  })
  depends_on = [module.eks]
}

resource "kubectl_manifest" "cluster_role_bindings" {
  for_each = length(var.workload_namespaces) > 0 && var.enable_custom_rbac ? var.rbac_map_cluster_role_bindings : {}

  yaml_body = yamlencode({
    apiVersion = "rbac.authorization.k8s.io/v1"
    kind       = "ClusterRoleBinding"
    metadata = {
      name = each.key
    }
    roleRef = {
      apiGroup = "rbac.authorization.k8s.io"
      kind     = each.value.roleRef.kind
      name     = each.value.roleRef.name
    }
    subjects = [
      {
        kind     = each.value.subject.kind
        name     = each.value.subject.name
        apiGroup = "rbac.authorization.k8s.io"
      }
    ]
  })
  depends_on = [module.eks]
}

resource "kubectl_manifest" "namespaced_role_bindings" {
  for_each = length(var.workload_namespaces) > 0 && var.enable_custom_rbac ? var.rbac_map_namespaced_role_bindings : {}

  yaml_body = yamlencode({
    apiVersion = "rbac.authorization.k8s.io/v1"
    kind       = "RoleBinding"
    metadata = {
      name      = each.key
      namespace = each.value.namespace
    }
    roleRef = {
      apiGroup = "rbac.authorization.k8s.io"
      kind     = each.value.roleRef.kind
      name     = each.value.roleRef.name
    }
    subjects = [
      {
        kind     = each.value.subject.kind
        name     = each.value.subject.name
        apiGroup = "rbac.authorization.k8s.io"
      }
    ]
  })

  depends_on = [
    module.eks,
    kubernetes_namespace.workloads
  ]
}
