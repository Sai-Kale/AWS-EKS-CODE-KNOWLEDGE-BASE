#-------------------------------
# Cluster Autoscaler IAM Resources
#-------------------------------

resource "aws_iam_role" "cluster_autoscaler" {
  count = var.enable_cluster_autoscaler ? 1 : 0
  name  = "${var.cluster_name}-cluster-autoscaler-role"

  tags = var.tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.oidc_provider}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${local.oidc_provider}:aud" = "sts.amazonaws.com"
            "${local.oidc_provider}:sub" = "system:serviceaccount:kube-system:cluster-autoscaler"
          }
        }
      }
    ]
  })
  
  depends_on = [module.eks]
}

resource "aws_iam_policy" "cluster_autoscaler" {
  count       = var.enable_cluster_autoscaler ? 1 : 0
  name        = "${var.cluster_name}-cluster-autoscaler-policy"
  description = "IAM policy for cluster autoscaler on ${var.cluster_name}"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeScalingActivities",
          "autoscaling:DescribeTags",
          "ec2:DescribeImages",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:GetInstanceTypesFromInstanceRequirements",
          "eks:DescribeNodegroup"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:ResourceTag/k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {
  count      = var.enable_cluster_autoscaler ? 1 : 0
  role       = aws_iam_role.cluster_autoscaler[0].name
  policy_arn = aws_iam_policy.cluster_autoscaler[0].arn
}

#-------------------------------
# Cluster Autoscaler Helm Release
#-------------------------------

resource "helm_release" "cluster_autoscaler" {
  count      = var.enable_cluster_autoscaler ? 1 : 0
  chart      = "cluster-autoscaler"
  name       = "cluster-autoscaler"
  namespace  = "kube-system"
  version    = var.cluster_autoscaler_version
  repository = "https://artifactory.spectrumflow.net/artifactory/helm"

  repository_username = local.artifactory_username
  repository_password = local.artifactory_password

  values = [
    templatefile("${path.module}/addons/values/cluster-autoscaler.yaml", {
      cluster_name = var.cluster_name
      aws_region   = data.aws_region.current.name
      role_arn     = aws_iam_role.cluster_autoscaler[0].arn
    }),
    yamlencode(try(var.cluster_autoscaler_helm_values, {}))
  ]
  
  depends_on = [
    module.eks,
    aws_iam_role.cluster_autoscaler,
    aws_iam_policy.cluster_autoscaler,
    aws_iam_role_policy_attachment.cluster_autoscaler,
    kubernetes_namespace.addon_namespaces,
    kubernetes_secret_v1.docker_registry_secret
  ]
}