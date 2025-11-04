resource "aws_s3_bucket" "backup" {
  count  = var.enable_velero && var.velero_create_bucket ? 1 : 0
  bucket = local.bucket_name

  tags = var.tags
}

resource "aws_s3_bucket_public_access_block" "block_access" {
  count  = var.enable_velero && var.velero_create_bucket ? 1 : 0
  bucket = aws_s3_bucket.backup[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  depends_on = [aws_s3_bucket.backup]
}

resource "aws_iam_role" "velero-role" {
  count = var.enable_velero ? 1 : 0
  name  = "${var.cluster_name}-velero-sa"
  assume_role_policy = templatefile("${path.module}/addons/policies/velero-assume-role.json", {
    AWS_ACCOUNT_ID  = data.aws_caller_identity.current.account_id
    OIDC_PROVIDER   = local.oidc_provider
    NAMESPACE       = "velero"
    SERVICE_ACCOUNT = "velero-server"
  })
  tags = var.tags
}

resource "aws_iam_policy" "velero-s3-policy" {
  count       = var.enable_velero ? 1 : 0
  name        = "${var.cluster_name}-velero-s3"
  description = "S3 bucket policy for velero for ${var.cluster_name}"

  policy = templatefile("${path.module}/addons/policies/velero-s3-policy.json", {
    BUCKET = local.bucket_name
  })
}

resource "aws_iam_role_policy_attachment" "s3-policy-attachment" {
  count      = var.enable_velero ? 1 : 0
  policy_arn = aws_iam_policy.velero-s3-policy[0].arn
  role       = aws_iam_role.velero-role[0].name
  depends_on = [aws_iam_role.velero-role, aws_iam_policy.velero-s3-policy]
}

resource "helm_release" "velero" {
  count      = var.enable_velero ? 1 : 0
  chart      = "velero"
  name       = "velero"
  namespace  = "velero"
  version    = var.velero_version
  repository = "https://vmware-tanzu.github.io/helm-charts"
  values = [
    templatefile("${path.module}/addons/values/velero.yaml", {
      cluster_name         = var.cluster_name
      disable_frequent     = var.velero_disable_frequent
      disable_longterm     = var.velero_disable_longterm
      frequent_schedule    = var.velero_frequent_schedule
      longterm_schedule    = var.velero_longterm_schedule
      velero_backup_bucket = local.bucket_name
      ROLE_ARN             = aws_iam_role.velero-role[0].arn
    }),
    yamlencode(try(var.velero_helm_values, {}))
  ]
  depends_on = [kubernetes_namespace.addon_namespaces, kubernetes_secret_v1.docker_registry_secret]
}
