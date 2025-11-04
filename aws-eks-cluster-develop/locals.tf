locals {
  admin_role         = [for arn in data.aws_iam_roles.admin_roles.arns : arn]
  subadmin_role      = [for arn in data.aws_iam_roles.sub_admin_roles.arns : arn]
  additional_roles   = [for k, v in { for key, value in data.aws_iam_roles.additional_roles : key => one(value["arns"]) if one(value["arns"]) != null } : v]
  admin_access_roles = concat(local.admin_role, local.subadmin_role, local.additional_roles)

  admin_access_entries = {
    for index, arn in local.admin_access_roles : "admin_role_${index}" => {
      kubernetes_groups = []
      principal_arn     = arn
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            namespaces = []
            type       = "cluster"
          }
        }
      }
    }
  }

  worker_additional_security_group_rules = {
    for k, v in var.worker_additional_security_group_rules : k => {
      description              = "Ingress from ${v.source_security_group_id}"
      protocol                 = v.protocol
      from_port                = v.from_port
      to_port                  = v.to_port
      type                     = "ingress"
      source_security_group_id = v.source_security_group_id
    }
  }
  node_security_group_additional_rules = {
    ng_ingress_cluster_to_node_all = {
      description                   = "Ingress from cluster to nodes (common service ports)"
      protocol                      = "-1"
      from_port                     = 80
      to_port                       = 65535
      type                          = "ingress"
      source_cluster_security_group = true
    }
    ng_ingress_self_all = {
      description = "Ingress from nodes to nodes  (common service ports)"
      protocol    = "-1"
      from_port   = 80
      to_port     = 65535
      type        = "ingress"
      self        = true
    }
  }

  nodegroup_security_group_all_additional_rules = merge(var.node_security_group_additional_rules, local.node_security_group_additional_rules, local.worker_additional_security_group_rules)

  worker_iam_role_additional_policies = merge(var.worker_iam_role_additional_policies, { for k, v in local.worker_node_ssm_managed_iam_polices : k => v })
  worker_node_ssm_managed_iam_polices = {
    amazonssmmanagedinstancecore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    amazonssmpatchassociation    = "arn:aws:iam::aws:policy/AmazonSSMPatchAssociation"
    amazoneksworkernode          = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    amazonekscni                 = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    amazoncontainerregistryro    = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    amazonec2readonlyaccess      = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
  }

  public_access_security_group_additional_rules = {
    for item in var.cluster_endpoint_public_access_cidrs : item => {
      description              = "public access allowlist cidr ${item} to cluster API Private Endpoint"
      protocol                 = "tcp"
      from_port                = 443
      to_port                  = 443
      type                     = "ingress"
      cidr_blocks              = [item]
      source_security_group_id = null
    }
  }

  subnet_cluster_security_group_additional_rules = {
    for item in data.aws_subnet.eks_subnets : item.id => {
      description              = "Private subnet ${item.id} to cluster API Private Endpoint"
      protocol                 = "tcp"
      from_port                = 443
      to_port                  = 443
      type                     = "ingress"
      cidr_blocks              = [item.cidr_block]
      source_security_group_id = null
    }
  }

  pod_subnet_cluster_security_group_additional_rules = {
    for item in data.aws_subnet.node_subnets : item.id => {
      description              = "Local subnet ${item.id} to cluster API Private Endpoint"
      protocol                 = "tcp"
      from_port                = 443
      to_port                  = 443
      type                     = "ingress"
      cidr_blocks              = [item.cidr_block]
      source_security_group_id = null
    }
  }

  cluster_egress_security_group_additional_rules = {
    cluster_egress_api_ng = {
      description                   = "Cluster API to node groups"
      protocol                      = "TCP"
      from_port                     = 443
      to_port                       = 443
      type                          = "egress"
      source_cluster_security_group = true
      source_security_group_id      = module.eks.node_security_group_id
    }
    cluster_egress_api_kubelet = {
      description                   = "Cluster API to node kubelets"
      protocol                      = "TCP"
      from_port                     = 10250
      to_port                       = 10250
      type                          = "egress"
      source_cluster_security_group = true
      source_security_group_id      = module.eks.node_security_group_id
    }
  }

  ssm_keys = { for key in var.credentials : key.path => key.name if key.provider == "ssm" }
  ssm_credentials = {
    for key in var.credentials : key.name => {
      path  = key.path
      value = data.aws_ssm_parameter.ssm_keys[key.path].value
    } if key.provider == "ssm"
  }
  asm_keys        = { for key in var.credentials : key.name => key.path if key.provider == "asm" }
  asm_credentials = try(jsondecode(data.aws_secretsmanager_secret_version.secret_version["cluster_bootstrap"].secret_string), null)

  artifactory_username = local.asm_credentials != null ? local.asm_credentials["artifactory_username"] : local.ssm_credentials["artifactory_username"].value
  artifactory_password = local.asm_credentials != null ? local.asm_credentials["artifactory_password"] : local.ssm_credentials["artifactory_password"].value
  splunk_token         = local.asm_credentials != null ? local.asm_credentials["splunk_token"] : local.ssm_credentials["splunk_token"].value
  datadog_app_key      = try(local.asm_credentials != null ? local.asm_credentials["datadog_app_key"] : local.ssm_credentials["datadog_app_key"].value, "")
  datadog_api_key      = local.asm_credentials != null ? local.asm_credentials["datadog_api_key"] : local.ssm_credentials["datadog_api_key"].value
  contrast_api_key     = var.enable_contrast_agent ? (local.asm_credentials != null ? local.asm_credentials["contrast_api_key"] : local.ssm_credentials["contrast_api_key"].value) : null
  contrast_service_key = var.enable_contrast_agent ? (local.asm_credentials != null ? local.asm_credentials["contrast_service_key"] : local.ssm_credentials["contrast_service_key"].value) : null
  contrast_username    = var.enable_contrast_agent ? (local.asm_credentials != null ? local.asm_credentials["contrast_username"] : local.ssm_credentials["contrast_username"].value) : null
  bucket_name          = try(var.velero_create_bucket && var.velero_s3_bucket_name == null ? "${var.cluster_name}-velero-backups" : var.velero_s3_bucket_name, "")

  oidc_provider = module.eks.oidc_provider

  # alb
  alb_scheme       = var.alb_internal ? "internal" : "internet-facing"
  alb_listen_port  = var.alb_internal ? "[{\"HTTP\":80}]" : "[{\"HTTP\":80},{\"HTTPS\":443}]"
  alb_ssl_redirect = var.alb_internal ? null : "{\"Type\": \"redirect\", \"RedirectConfig\": { \"Protocol\": \"HTTPS\", \"Port\": \"443\", \"StatusCode\": \"HTTP_301\"}}"


  # add ons

  base_addon_namespaces      = ["datadog", "falcon-system", "metrics-server"]
  istio_namespace            = var.enable_istio ? ["istio-system", "istio-ingress"] : []
  nginx_namespace            = var.enable_nginx ? ["nginx"] : []
  cert_manager_namespace     = var.enable_cert_manager ? ["cert-manager"] : []
  pod_reloader_namespace     = var.enable_pod_reloader ? ["pod-reloader"] : []
  external_secrets_namespace = var.enable_external_secrets ? ["external-secrets"] : []
  velero_namespace           = var.enable_velero ? ["velero"] : []
  meta_controller_namespace  = var.enable_metacontroller ? ["meta-controller"] : []
  external_dns_namespace     = var.enable_external_dns ? ["external-dns"] : []
  alb_controller_namespace   = var.create_alb ? ["aws-load-balancer-controller"] : []
  otel_namespace             = var.enable_otel ? ["otel-splunk"] : []
  fluentd_namespace          = var.enable_otel ? [] : ["fluentd"]

  all_addon_namespaces = distinct(concat(
    local.base_addon_namespaces,
    local.istio_namespace,
    local.nginx_namespace,
    local.cert_manager_namespace,
    local.pod_reloader_namespace,
    local.external_secrets_namespace,
    local.velero_namespace,
    local.meta_controller_namespace,
    local.external_dns_namespace,
    local.alb_controller_namespace,
    local.otel_namespace,
    local.fluentd_namespace
  ))

  istio_ingresses_map = length(var.istio_ingresses) > 0 ? var.istio_ingresses : {
    default = {
      name                          = "istio-ingress"
      alb_ssl_redirect              = local.alb_ssl_redirect
      alb_certificate_arn           = var.alb_certificate_arn
      alb_listen_port               = local.alb_listen_port
      alb_scheme                    = local.alb_scheme
      alb_tls_policy                = var.alb_tls_policy
      alb_additional_security_group = var.alb_additional_security_group
      alb_waf_arn                   = var.alb_waf_arn
      ingress_class_name            = "alb"
    }
  }

  nginx_ingresses_map = length(var.nginx_ingresses) > 0 ? var.nginx_ingresses : {
    default = {
      name                          = var.ingress_name
      alb_ssl_redirect              = local.alb_ssl_redirect
      alb_certificate_arn           = var.alb_certificate_arn
      alb_listen_port               = local.alb_listen_port
      alb_scheme                    = local.alb_scheme
      alb_tls_policy                = var.alb_tls_policy
      alb_additional_security_group = var.alb_additional_security_group
      alb_waf_arn                   = var.alb_waf_arn
    }
  }
}
