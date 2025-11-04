resource "aws_iam_role" "alb-controller-role" {
  count = var.create_alb ? 1 : 0
  name  = "${var.cluster_name}-alb-role"

  tags = var.tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.oidc_provider}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${local.oidc_provider}:aud" : "sts.amazonaws.com",
            "${local.oidc_provider}:sub" : "system:serviceaccount:aws-load-balancer-controller:aws-load-balancer-controller"
          }
        }
      }
    ]
  })
  depends_on = [module.eks]
}

resource "aws_iam_policy" "alb-controller-policy" {
  count       = var.create_alb ? 1 : 0
  name        = "${var.cluster_name}_alb_policy"
  description = "${var.cluster_name} ALB policy"
  policy      = file("${path.module}/addons/policies/iam_policy.json")

  tags = var.tags
}
resource "aws_iam_role_policy_attachment" "alb-attachment" {
  count      = var.create_alb ? 1 : 0
  role       = aws_iam_role.alb-controller-role[0].name
  policy_arn = aws_iam_policy.alb-controller-policy[0].arn
}

resource "helm_release" "alb-controller" {
  count      = var.create_alb ? 1 : 0
  chart      = "aws-load-balancer-controller"
  name       = "aws-load-balancer-controller"
  namespace  = "aws-load-balancer-controller"
  version    = var.alb_controller_version
  repository = "https://artifactory.spectrumflow.net/artifactory/helm"

  repository_username = local.artifactory_username
  repository_password = local.artifactory_password

  values = [
    templatefile("${path.module}/addons/values/alb_controller.yaml", {
      cluster_name = var.cluster_name
      vpc_id       = data.aws_vpc.vpc.id
      region       = data.aws_region.current.name
      node_subnets = join(",", var.public_subnets)
      role_arn     = aws_iam_role.alb-controller-role[0].arn
    })
  ]
  depends_on = [
    aws_iam_role.alb-controller-role, aws_iam_policy.alb-controller-policy,
    aws_iam_role_policy_attachment.alb-attachment, kubernetes_namespace.addon_namespaces, kubernetes_secret_v1.docker_registry_secret
  ]
}

resource "helm_release" "istio-base" {
  count               = var.enable_istio ? 1 : 0
  chart               = "base"
  name                = "istio-base"
  namespace           = "istio-system"
  version             = var.istio_version
  repository          = "https://artifactory.spectrumflow.net/artifactory/istio-public-helm"
  repository_username = local.artifactory_username
  repository_password = local.artifactory_password
  depends_on          = [module.eks, helm_release.alb-controller]
}

resource "helm_release" "istiod" {
  count               = var.enable_istio ? 1 : 0
  chart               = "istiod"
  name                = "istiod"
  namespace           = "istio-system"
  version             = var.istio_version
  repository          = "https://artifactory.spectrumflow.net/artifactory/istio-public-helm"
  repository_username = local.artifactory_username
  repository_password = local.artifactory_password
  set = [
    {
      name  = "pilot.image"
      value = "docker-artifactory.spectrumflow.net/docker/istio/pilot:${var.istio_version}"
    },
    {
      name  = "global.proxy.image"
      value = "docker-artifactory.spectrumflow.net/docker/istio/proxyv2:${var.istio_version}"
    },
    {
      name  = "global.imagePullSecrets[0]"
      value = "docker-artifactory"
    }
  ]
  depends_on = [module.eks, helm_release.istio-base]
}

resource "helm_release" "istio-ingress" {
  count               = var.enable_istio ? 1 : 0
  chart               = "gateway"
  name                = "istio-ingress"
  namespace           = "istio-ingress"
  version             = var.istio_version
  repository          = "https://artifactory.spectrumflow.net/artifactory/istio-public-helm"
  repository_username = local.artifactory_username
  repository_password = local.artifactory_password
  set = [
    {
      name  = "service.type"
      value = "NodePort"
    }
  ]
  depends_on = [module.eks, helm_release.istiod]
}

resource "kubernetes_ingress_class_v1" "istio" {
  count = var.enable_istio ? 1 : 0
  metadata {
    name = "istio"
    annotations = {
      "ingressclass.kubernetes.io/is-default-class" : "true"
    }
  }
  spec {
    controller = "istio.io/ingress-controller"
  }
}

resource "kubernetes_ingress_v1" "ingress" {
  for_each = var.create_alb && var.enable_istio ? local.istio_ingresses_map : {}

  metadata {
    name      = each.value.name
    namespace = "istio-ingress"
    annotations = {
      "alb.ingress.kubernetes.io/backend-protocol" : "HTTP",
      "alb.ingress.kubernetes.io/actions.ssl-redirect" : each.value.alb_ssl_redirect,
      "alb.ingress.kubernetes.io/certificate-arn" : each.value.alb_certificate_arn,
      "alb.ingress.kubernetes.io/healthcheck-path" : "/healthz/ready",
      "alb.ingress.kubernetes.io/healthcheck-port" : "status-port",
      "alb.ingress.kubernetes.io/healthcheck-protocol" : "HTTP",
      "alb.ingress.kubernetes.io/listen-ports" : each.value.alb_listen_port,
      "alb.ingress.kubernetes.io/load-balancer-attributes" : "routing.http2.enabled=true",
      "alb.ingress.kubernetes.io/scheme" : each.value.alb_scheme,
      "alb.ingress.kubernetes.io/ssl-policy" : each.value.alb_tls_policy,
      "alb.ingress.kubernetes.io/success-codes" : "200",
      "alb.ingress.kubernetes.io/target-type" : "instance",
      "alb.ingress.kubernetes.io/security-groups" : join(",", each.value.alb_additional_security_group),
      "alb.ingress.kubernetes.io/subnets" : join(",", var.public_subnets),
      "alb.ingress.kubernetes.io/manage-backend-security-group-rules" : "true",
      "alb.ingress.kubernetes.io/wafv2-acl-arn" : each.value.alb_waf_arn,
    }
  }
  spec {
    ingress_class_name = each.value.ingress_class_name
    rule {
      http {
        path {
          path = "/*"
          backend {
            service {
              name = "ssl-redirect"
              port {
                name = "use-annotation"
              }
            }
          }
        }
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "istio-ingress"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
  wait_for_load_balancer = true
  lifecycle {
    create_before_destroy = false
  }

  depends_on = [helm_release.alb-controller, helm_release.istio-ingress, kubernetes_namespace.addon_namespaces, kubernetes_secret_v1.docker_registry_secret]
}
resource "helm_release" "nginx-ingress" {
  count      = var.enable_nginx == true ? 1 : 0
  chart      = "ingress-nginx"
  name       = var.ingress_name
  version    = var.nginx_version
  namespace  = "nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"

  values = [templatefile("${path.module}/addons/values/nginx.yaml", {}),
    var.nginx_custom_value_file
  ]


  depends_on = [module.eks, helm_release.alb-controller, kubernetes_namespace.addon_namespaces, kubernetes_secret_v1.docker_registry_secret]
}

resource "kubernetes_ingress_v1" "nginx-ingress" {
  for_each = var.create_alb && var.enable_nginx ? local.nginx_ingresses_map : {}

  metadata {
    name      = each.value.name
    namespace = "nginx"
    annotations = {
      "alb.ingress.kubernetes.io/backend-protocol" : "HTTP",
      "alb.ingress.kubernetes.io/actions.ssl-redirect" : each.value.alb_ssl_redirect,
      "alb.ingress.kubernetes.io/certificate-arn" : each.value.alb_certificate_arn,
      "alb.ingress.kubernetes.io/healthcheck-path" : "/healthz/ready",
      "alb.ingress.kubernetes.io/listen-ports" : each.value.alb_listen_port,
      "alb.ingress.kubernetes.io/load-balancer-attributes" : "routing.http2.enabled=true",
      "alb.ingress.kubernetes.io/scheme" : each.value.alb_scheme,
      "alb.ingress.kubernetes.io/ssl-policy" : each.value.alb_tls_policy,
      "alb.ingress.kubernetes.io/success-codes" : "200,404",
      "alb.ingress.kubernetes.io/target-type" : "instance",
      "alb.ingress.kubernetes.io/security-groups" : join(",", each.value.alb_additional_security_group),
      "alb.ingress.kubernetes.io/subnets" : join(",", var.public_subnets),
      "alb.ingress.kubernetes.io/wafv2-acl-arn" : each.value.alb_waf_arn,
    }
  }
  spec {
    ingress_class_name = "alb"
    rule {
      http {
        path {
          path = "/*"
          backend {
            service {
              name = "ssl-redirect"
              port {
                name = "use-annotation"
              }
            }
          }
        }
        path {
          path = "/*"
          backend {
            service {
              name = "${var.ingress_name}-controller"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
  wait_for_load_balancer = true

  lifecycle {
    create_before_destroy = false
  }

  depends_on = [helm_release.alb-controller, helm_release.nginx-ingress]
}
