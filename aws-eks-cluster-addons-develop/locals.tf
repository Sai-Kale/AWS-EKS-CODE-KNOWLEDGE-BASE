locals {
  account_number = data.aws_caller_identity.current.id
  oidc           = trim(data.aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://")
  oidc_arn       = "arn:aws:iam::${local.account_number}:oidc-provider/${local.oidc}"
  node_subnets   = [for each in var.node_group_subnets : { id : each }]
  tags = merge(var.tags, {
    app_id     = var.app_id
    cost_code  = var.cost_code
    app_ref_id = var.app_ref_id
  })

  pass_role_arn = var.enable_karpenter_iam ? "arn:aws:iam::${local.account_number}:role/${var.cluster_name}-karpenter-node-role" : "arn:aws:iam::${local.account_number}:role/${var.cluster_name}-ng"

}
