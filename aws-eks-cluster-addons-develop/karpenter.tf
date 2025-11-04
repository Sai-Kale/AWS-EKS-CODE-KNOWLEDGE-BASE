resource "helm_release" "karpenter-crd" {
  count               = var.enable_karpenter ? 1 : 0
  chart               = "karpenter-crd"
  name                = "karpenter-crd"
  namespace           = "karpenter"
  version             = var.karpenter_version
  repository          = "oci://public.ecr.aws/karpenter"
  repository_username = data.aws_ecrpublic_authorization_token.ecr_token.user_name
  repository_password = data.aws_ecrpublic_authorization_token.ecr_token.password
  create_namespace    = true
}

resource "helm_release" "karpenter" {
  count               = var.enable_karpenter ? 1 : 0
  chart               = "karpenter"
  name                = "karpenter"
  namespace           = "karpenter"
  version             = var.karpenter_version
  repository          = "oci://public.ecr.aws/karpenter"
  repository_username = data.aws_ecrpublic_authorization_token.ecr_token.user_name
  repository_password = data.aws_ecrpublic_authorization_token.ecr_token.password
  create_namespace    = true

  values = concat(
    [
      templatefile("${path.module}/values/karpenter.yaml", {
        cluster_name     = var.cluster_name
        account_number   = local.account_number
        cluster_endpoint = data.aws_eks_cluster.eks.endpoint
      })
    ],
    [
      yamlencode(lookup(var.override_values, "karpenter", tomap({})))
    ]
  )
  depends_on = [
    helm_release.karpenter-crd,
    aws_eks_access_entry.node-access,
    aws_eks_access_entry.node-controller-access,
  ]
}

resource "kubernetes_manifest" "nodegroup" {
  count = var.enable_karpenter && var.enable_karpenter_custom_resource ? 1 : 0
  manifest = {
    "apiVersion" = "karpenter.sh/v1beta1"
    "kind"       = "NodePool"
    "metadata" = {
      "name" = "default"
    }
    spec = {
      "template" = {
        spec = {
          requirements = [
            {
              key      = "kubernetes.io/arch"
              operator = "In"
              values   = ["amd64"]
            },
            {
              key      = "kubernetes.io/os"
              operator = "In"
              values   = ["linux"]
            },
            {
              key      = "karpenter.sh/capacity-type"
              operator = "In"
              values   = var.karpenter_capacity_type
            },
            {
              key      = "karpenter.k8s.aws/instance-category"
              operator = "In"
              values   = var.karpenter_instance_category
            },
            {
              key      = "karpenter.k8s.aws/instance-generation"
              operator = "In"
              values   = var.karpenter_instance_generation
            },
            {
              key      = "karpenter.k8s.aws/instance-cpu"
              operator = "In"
              values   = var.karpenter_instance_cpu
            },
          ]
          nodeClassRef = {
            apiVersion = "karpenter.k8s.aws/v1beta1"
            kind       = "EC2NodeClass"
            name       = var.karpenter_node_class
          }
        }
      }
      "limits" = {
        cpu = 1000
      }
      disruption = {
        consolidationPolicy = "WhenUnderutilized"
        expireAfter         = "720h" # 30 * 24h = 720h
      }
    }
  }
  depends_on = [
    helm_release.karpenter-crd,
    helm_release.karpenter,
    kubernetes_manifest.nodeclass,
    aws_eks_access_entry.node-controller-access,
    aws_iam_role.karpenter_controller_role,
    aws_iam_policy.karpenter_controller_policy,
    aws_iam_role_policy_attachment.controller-role-attach,
  ]
}

resource "kubernetes_manifest" "nodeclass" {
  count = var.enable_karpenter && var.enable_karpenter_custom_resource ? 1 : 0
  manifest = {
    "apiVersion" = "karpenter.k8s.aws/v1beta1"
    "kind"       = "EC2NodeClass"
    "metadata" = {
      "name" = var.karpenter_node_class
    }
    spec = {
      amiFamily           = "AL2" # Amazon Linux 2
      role                = aws_iam_role.karpenter_node_role[0].name
      subnetSelectorTerms = local.node_subnets
      securityGroupSelectorTerms = [
        { tags = { "kubernetes.io/cluster/${var.cluster_name}" = "owned" } },
        { tags = { "karpenter.sh/discovery" : var.cluster_name } }
      ]

      amiSelectorTerms = [
        {
          name  = "charter_eks_${var.cluster_version}_amzn_2_ami_2024*",
          owner = "786534693165"
        },
      ]
    }
  }
  depends_on = [
    helm_release.karpenter-crd,
    helm_release.karpenter,
    aws_eks_access_entry.node-access,
    aws_iam_role.karpenter_node_role,
    aws_iam_policy.node_role_policy,
    aws_iam_role_policy_attachment.node-role-attach,
    aws_iam_instance_profile.karpenter_node_profile
  ]
}


resource "aws_iam_role" "karpenter_node_role" {
  count = var.enable_karpenter && var.enable_karpenter_iam == "true" ? 1 : 0
  name  = "${var.cluster_name}-karpenter-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_instance_profile" "karpenter_node_profile" {
  count = var.enable_karpenter && var.enable_karpenter_iam == "true" ? 1 : 0
  name  = "${var.cluster_name}-karpenter-node-profile"
  role  = aws_iam_role.karpenter_node_role[0].name
  tags  = var.tags
}

resource "aws_iam_policy" "node_role_policy" {
  count       = var.enable_karpenter && var.enable_karpenter_iam == "true" ? 1 : 0
  name        = "${var.cluster_name}-karpenter-profile-policy"
  description = "Karpenter Node Role Policy"

  policy = file("${path.module}/policies/karpenter_iam.json")

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "node-role-attach" {
  count      = var.enable_karpenter && var.enable_karpenter_iam == "true" ? 1 : 0
  role       = aws_iam_role.karpenter_node_role[0].name
  policy_arn = aws_iam_policy.node_role_policy[0].arn
}

resource "aws_iam_role_policy_attachment" "role-policy-attachment" {
  count      = var.enable_karpenter && var.enable_karpenter_iam == "true" ? length(var.karpenter_node_policies) : 0
  role       = aws_iam_role.karpenter_node_role[0].name
  policy_arn = var.karpenter_node_policies[count.index]
}


resource "aws_iam_policy" "karpenter_controller_policy" {
  count       = var.enable_karpenter ? 1 : 0
  name        = "${var.cluster_name}-karpenter-controller-policy"
  description = "karpenter-controller service account policy"

  policy = templatefile("${path.module}/policies/karpenter_policy.json", {
    cluster_name   = var.cluster_name
    account_number = local.account_number
    region         = data.aws_region.current.name
    pass_role_arn  = local.pass_role_arn
  })
  tags = var.tags
}

resource "aws_iam_role" "karpenter_controller_role" {
  count = var.enable_karpenter ? 1 : 0
  name  = format("${var.cluster_name}-karpenter-controller-role")

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Federated = local.oidc_arn
        }
      },
    ]
  })
  depends_on = [aws_iam_policy.karpenter_controller_policy]
  tags       = var.tags
}

resource "aws_iam_role_policy_attachment" "controller-role-attach" {
  count      = var.enable_karpenter ? 1 : 0
  role       = aws_iam_role.karpenter_controller_role[0].name
  policy_arn = aws_iam_policy.karpenter_controller_policy[0].arn
  depends_on = [aws_iam_role.karpenter_controller_role, aws_iam_policy.karpenter_controller_policy]
}

resource "aws_eks_access_entry" "node-controller-access" {
  count         = var.enable_karpenter && var.enable_karpenter_accessentry ? 1 : 0
  cluster_name  = var.cluster_name
  principal_arn = aws_iam_role.karpenter_controller_role[0].arn
  type          = "EC2_LINUX"
  tags          = var.tags
}

resource "aws_eks_access_entry" "node-access" {
  count         = var.enable_karpenter && var.enable_karpenter_accessentry ? 1 : 0
  cluster_name  = var.cluster_name
  principal_arn = aws_iam_role.karpenter_node_role[0].arn
  type          = "EC2_LINUX"
  tags          = var.tags
}
