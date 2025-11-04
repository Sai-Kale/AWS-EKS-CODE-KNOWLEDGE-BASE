data "aws_route53_zone" "primary" {
  count = var.enable_external_dns && var.aws_route53_zone != null && var.aws_route53_zone != "" ? 1 : 0
  name  = var.aws_route53_zone
}

data "aws_iam_policy_document" "external_dns_trust" {
  count = var.enable_external_dns ? 1 : 0
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:external-dns:external-dns"]
    }
  }
}

data "aws_iam_policy_document" "external_dns_policy" {
  count = var.enable_external_dns ? 1 : 0
  statement {
    actions   = ["route53:ChangeResourceRecordSets", "route53:ListResourceRecordSets"]
    resources = data.aws_route53_zone.primary != [] ? [data.aws_route53_zone.primary[0].arn] : []
  }
  statement {
    actions   = ["route53:ListHostedZones"]
    resources = ["*"]
  }
}

resource "helm_release" "external_dns" {
  count      = var.enable_external_dns && data.aws_route53_zone.primary != [] ? 1 : 0
  name       = "external-dns"
  chart      = "external-dns"
  namespace  = "external-dns"
  version    = var.external_dns_version
  repository = var.external_dns_repository

  repository_username = local.artifactory_username
  repository_password = local.artifactory_password

  values = [
    templatefile("${path.module}/addons/values/external-dns.yaml", {
      domain     = data.aws_route53_zone.primary != [] ? replace(data.aws_route53_zone.primary[0].name, "\\.$", "") : ""
      txt_prefix = var.external_dns_txt_prefix
      aws_region = var.aws_region
      role_arn   = aws_iam_role.external_dns[0].arn
    }),
    yamlencode(try(var.external_dns_helm_values, {}))
  ]

  depends_on = [kubernetes_namespace.addon_namespaces, kubernetes_secret_v1.docker_registry_secret]
}

resource "aws_iam_role" "external_dns" {
  count              = var.enable_external_dns ? 1 : 0
  name               = "external-dns-role"
  assume_role_policy = data.aws_iam_policy_document.external_dns_trust[0].json
}

resource "aws_iam_role_policy" "external_dns" {
  count  = var.enable_external_dns ? 1 : 0
  name   = "external-dns-policy"
  role   = aws_iam_role.external_dns[0].id
  policy = data.aws_iam_policy_document.external_dns_policy[0].json
}

