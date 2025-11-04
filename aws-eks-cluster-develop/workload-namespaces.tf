resource "kubernetes_namespace" "workloads" {
  for_each = toset(var.workload_namespaces)

  metadata {
    name   = each.key
    labels = lookup(var.workload_namespace_labels_map, each.key, {})
  }
  depends_on = [module.eks]
}