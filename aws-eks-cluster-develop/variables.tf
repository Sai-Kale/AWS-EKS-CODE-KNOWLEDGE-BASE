variable "vpc_id" {
  description = "VPC ID"
  type        = string
  default     = ""
}

variable "node_group_subnets" {
  description = "List of node subnet identifiers. Recommended to use local subnets"
  type        = set(string)
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "K8s version of the cluster"
  type        = string
}

variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled"
  type        = bool
  default     = true
}

variable "cluster_endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint"
  type        = list(string)
  default     = ["142.136.0.0/21"]
}

variable "create_cluster_security_group" {
  description = "Determines if a security group is created for the cluster. Note: the EKS service creates a primary security group for the cluster by default"
  type        = bool
  default     = true
}

variable "cluster_security_group_id" {
  description = "Existing security group ID to be attached to the cluster"
  type        = string
  default     = ""
}

variable "cluster_additional_security_group_ids" {
  description = "List of additional, externally created security group IDs to attach to the cluster control plane"
  type        = list(string)
  default     = []
}

variable "create_node_security_group" {
  description = "Determines whether to create a security group for the node groups or use the existing `node_security_group_id`"
  type        = bool
  default     = true
}

variable "cluster_security_group_additional_rules" {
  description = "List of additional security group rules to add to the cluster security group created. Set `source_node_security_group = true` inside rules to set the `node_security_group` as source"
  type = map(object({
    description              = string
    protocol                 = string
    from_port                = number
    to_port                  = number
    type                     = string
    cidr_blocks              = list(string)
    source_security_group_id = string
  }))
  default = {}
}
variable "create_iam_role" {
  description = "Determines whether a an IAM role is created or to use an existing IAM role"
  type        = bool
  default     = true
}
variable "iam_role_arn" {
  description = "Existing IAM role ARN for the cluster. Required if `create_iam_role` is set to `false`"
  type        = string
  default     = null
}
variable "iam_role_name" {
  description = "Name to use on IAM role created"
  type        = string
  default     = null
}
variable "iam_role_path" {
  description = "Cluster IAM role path"
  type        = string
  default     = null
}
variable "enable_cluster_creator_admin_permissions" {
  description = "Indicates whether or not to add the cluster creator (the identity used by Terraform) as an administrator via access entry"
  type        = bool
  default     = false
}

variable "enable_irsa" {
  description = "Determines whether to create an OpenID Connect Provider for EKS to enable IRSA"
  type        = bool
  default     = true
}

variable "access_entries" {
  description = "Map of access entries to add to the cluster"
  type = map(object({
    principal_arn     = string
    kubernetes_groups = optional(list(string), [])
    policy_associations = map(object({
      policy_arn = string
      access_scope = object({
        namespaces = list(string)
        type       = string
      })
    }))
  }))
  default = {}
}

variable "control_plane_subnets" {
  description = "Subnet IDs where EKS worker nodes will be created. Recommended private subnets"
  type        = set(string)
}

variable "create_cloudwatch_log_group" {
  description = "Determines whether a log group is created by this module for the cluster logs. If not, AWS will automatically create one if logging is enabled"
  type        = bool
  default     = false
}
variable "cloudwatch_log_group_retention_in_days" {
  description = "Number of days to retain log events. Default retention - 90 days"
  type        = number
  default     = 120
}
variable "cluster_enabled_log_types" {
  description = "A list of the desired control plane logs to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html)"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}
variable "kms_admin_roles" {
  description = "A list of IAM ARNs for [key administrators](https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html#key-policy-default-allow-administrators). If no value is provided, the current caller identity is used to ensure at least one key admin is available"
  type        = list(string)
  default     = []
}
variable "cluster_kms_key_deletion_window_in_days" {
  description = "The waiting period, specified in number of days. After the waiting period ends, AWS KMS deletes the KMS key. If you specify a value, it must be between `7` and `30`, inclusive. If you do not specify a value, it defaults to `30`"
  type        = number
  default     = 30
}
variable "node_security_group_additional_rules" {
  description = "List of additional security group rules to add to the node security group created. Set `source_cluster_security_group = true` inside rules to set the `cluster_security_group` as source"
  type = map(object({
    description                   = string
    protocol                      = string
    from_port                     = number
    to_port                       = number
    type                          = string
    source_cluster_security_group = optional(bool)
    self                          = optional(bool)
  }))
  default = {}
}

variable "ami_type" {
  description = "Type of Amazon Machine Image (AMI) associated with the EKS Node Group. See the [AWS documentation](https://docs.aws.amazon.com/eks/latest/APIReference/API_Nodegroup.html#AmazonEKS-Type-Nodegroup-amiType) for valid values"
  type        = string
  default     = "AL2023_x86_64_STANDARD"
}

variable "min_size" {
  description = "Minimum number of nodes of k8s cluster"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of nodes of k8s cluster"
  type        = number
  default     = 3
}

variable "desired_size" {
  description = "Desired number of nodes of k8s cluster"
  type        = number
  default     = 1
}

variable "post_bootstrap_user_data" {
  description = "user data to be run after bootstrap of the EKS cluster"
  type        = string
  default     = ""
}

variable "disk_size" {
  description = "Disk size of nodes of k8s cluster"
  type        = number
  default     = 100
}

variable "volume_iops" {
  default     = 3000
  type        = number
  description = "The number of I/O operations per second (IOPS) that the volume supports"
}

variable "volume_throughput" {
  default     = 150
  type        = number
  description = "Throughput of volume in mebibytes per second (MiBps)"
}
variable "capacity_type" {
  description = "Capacity type of nodes of k8s cluster"
  type        = string
  default     = "ON_DEMAND"
}

variable "create_launch_template" {
  description = "Determines if the launch template to be created for the EKS cluster"
  type        = bool
  default     = true
}
variable "force_update_version" {
  description = "Force version update if existing pods are unable to be drained due to a pod disruption budget issue"
  type        = bool
  default     = true
}
variable "instance_types" {
  description = "Node instance types"
  type        = list(string)
  default     = ["m5.xlarge"]
}

variable "ami_id" {
  description = "Node AMI Id"
  type        = string
  default     = null
}

variable "node_group_metadata_options" {
  description = "Node metadata options"
  type = object({
    http_endpoint               = optional(string)
    http_tokens                 = optional(string)
    http_put_response_hop_limit = optional(number)
  })
  default = {
    http_endpoint               = "enabled"
    http_tokens                 = "optional"
    http_put_response_hop_limit = 2
  }
}

variable "enable_bootstrap_user_data" {
  description = "Determines if the user data for bootstrapping the cluster is to be enabled"
  type        = bool
  default     = true
}
variable "bootstrap_extra_args" {
  description = "Bootstrap extra args"
  type        = string
  default     = ""
}

variable "worker_iam_role_additional_policies" {
  description = "Additional IAM policies to be attached to the worker nodes"
  type        = map(string)
  default     = {}
}

variable "cluster_addons" {
  description = "Map of addon configurations for cluster addons (vpc-cni, coredns, kube-proxy)"
  type        = any
  default     = {}
}

variable "worker_additional_security_group_rules" {
  description = "List of SG rules to be added to the worker nodes SG"
  type = map(object({
    protocol                 = string
    from_port                = number
    to_port                  = number
    source_security_group_id = string
  }))
  default = {}
}

variable "cluster_ip_family" {
  description = "The IP family used to assign Kubernetes pod and service addresses. Valid values are `ipv4` (default) and `ipv6`. You can only specify an IP family when you create a cluster, changing this value will force a new cluster to be created"
  type        = string
  default     = "ipv4"
}

variable "create_cni_ipv6_iam_policy" {
  description = "Determines whether to create an [`AmazonEKS_CNI_IPv6_Policy`](https://docs.aws.amazon.com/eks/latest/userguide/cni-iam-role.html#cni-iam-role-create-ipv6-policy)"
  type        = bool
  default     = false
}

variable "enable_amazon_eks_vpc_cni_custom_networking" {
  description = "Enable VPC Custom Networking"
  type        = bool
  default     = false
}

variable "automatic_ami_update_enabled" {
  description = "Enable automatic AMI updates for the EKS node group"
  type        = bool
  default     = true
}

variable "admin_role_regex" {
  default     = "AWSReservedSSO_CloudAdministratorAccess*"
  type        = string
  description = "Cloud Admin regex name to be used to find SSO admin role for cluster access"
}

variable "sub_admin_role_regex" {
  default     = "AWSReservedSSO_subaccount_admins*"
  type        = string
  description = "Sub Admin regex name to be used to find SSO sub admin role for cluster access"
}

variable "additional_admin_role_regex" {
  default     = [".*_k8s_runner_instance_role", ".*_platform_runner_role"]
  type        = set(string)
  description = "Additional regex of aws roles to be used to for cluster access"
}

## Addons

variable "splunk_index" {
  type        = string
  description = "Splunk Index"
  default     = "aws-sa-prod"
}

variable "public_subnets" {
  description = "List of node subnet identifiers."
  type        = set(string)
  default     = []
}

variable "credentials" {
  description = "Map of credentials with provider config. Must have artifactory_username, artifactory_password, datadog_api_key"
  type = list(object({
    name     = string
    provider = optional(string, "ssm")
    path     = string
  }))
}

variable "splunk_host" {
  default     = "aws-cribl-hec.tools.prd.spectrum.net"
  description = "Splunk host"
  type        = string
}

variable "falcon_cid" {
  description = "Falcon CID"
  type        = string
}

variable "falcon_client" {
  description = "Falcon Client"
  type        = string
}

variable "falcon_secret" {
  description = "Falcon Secret"
  type        = string
}

variable "falcon_proxy_url" {
  description = "Falcon proxy URL"
  type        = string
  default     = "https://crowdstrike-squid-proxy-svc.meta.spectrum.net:3128"
}

variable "alb_certificate_arn" {
  default     = null
  type        = string
  description = "AWS Certificate arn"
}

variable "alb_tls_policy" {
  default     = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
  type        = string
  description = "ALB TLS policy"
}

variable "alb_internal" {
  default     = false
  type        = bool
  description = "If alb is internal"
}

variable "alb_additional_security_group" {
  description = "List of additional, externally created security group IDs to attach to the alb"
  type        = set(string)
  default     = []
}

variable "alb_waf_arn" {
  description = "Waf arn to be added to the ALB"
  type        = string
  default     = null
}

variable "datadog_helm_values" {
  default     = null
  type        = any
  description = "Datadog helm values"
}

variable "fluentd_helm_values" {
  default     = null
  type        = any
  description = "Fluentd helm values"
}

variable "cluster_autoscaler_helm_values" {
  default     = null
  type        = map(any)
  description = "Cluster Autoscaler helm values"
}

variable "external_dns_helm_values" {
  default     = null
  type        = map(any)
  description = "External DNS helm values"
}

variable "pod_reloader_helm_values" {
  default     = null
  type        = any
  description = "pod reloader helm values"
}

## Addon Versions
variable "falcon_kac_chart_version" {
  default     = "1.2.0"
  type        = string
  description = "Falcon KAC helm version"
}

variable "falcon_kac_image_tag" {
  default     = "7.21.0-1904.container.x86_64.Release.US-2"
  type        = string
  description = "Falcon KAC Docker Image Tag"
}
variable "falcon_iar_chart_version" {
  default     = "1.1.8"
  type        = string
  description = "Falcon Image Analyzer Chart Version"
}
variable "falcon_iar_image_tag" {
  default     = "1.0.16"
  type        = string
  description = "Falcon Image Analyzer docker image Version"
}
variable "fluentd_version" {
  default     = "1.4.7-multiline.regex.4"
  type        = string
  description = "Fluentd Version"
}

variable "cluster_autoscaler_version" {
  default     = "9.37.0"
  type        = string
  description = "Cluster Autoscaler Version"
}

variable "istio_version" {
  default     = "1.26.1"
  type        = string
  description = "Istio Version"
}

variable "datadog_version" {
  default     = "3.89.0"
  type        = string
  description = "Datadog Version"
}

variable "metric_server_version" {
  default     = "3.8.2"
  type        = string
  description = "Metric Server Version"
}

variable "alb_controller_version" {
  default     = "1.8.1"
  type        = string
  description = "ALB Controller Vrsion"
}

variable "enable_contrast_agent" {
  default     = true
  type        = bool
  description = "Enable the Contrast Agent addon with default values. Note: Contrast Agent is required for SDIT Applications."
}

variable "contrast_agent_operator_version" {
  default     = "1.5.4"
  type        = string
  description = "Contrast Agent operator Version"
}

variable "contrast_agent_environment" {
  default     = "DEVELOPMENT"
  type        = string
  description = "Contrast Agent operator environment. DEVELOPMENT, QA, PROD"
}

variable "nginx_version" {
  default     = "4.12.0"
  type        = string
  description = "nginx ingress chart version"
}

variable "cert_manager_version" {
  default     = "v1.16.3"
  type        = string
  description = "cert manager chart version"
}

variable "pod_reloader_version" {
  default     = "1.2.1"
  type        = string
  description = "pod reloader chart version"
}

variable "ingress_name" {
  default     = "ingress-nginx"
  type        = string
  description = "Release name for nginx ingress"
}
variable "nginx_custom_value_file" {
  default     = ""
  type        = string
  description = "Custom nginx helm values file"
}

## Enable
variable "create_alb" {
  default     = true
  type        = bool
  description = "Variable to create the actual ALB"
}

variable "enable_cluster_autoscaler" {
  default     = true
  type        = bool
  description = "Enable cluster autoscaler"
}

variable "enable_istio" {
  default     = true
  type        = bool
  description = "Enable istio for cluster"
}

variable "enable_nginx" {
  default     = false
  type        = bool
  description = "Enable nginx ingress for cluster"
}

variable "enable_cert_manager" {
  default     = false
  type        = bool
  description = "Enable cert manager for cluster"
}

variable "enable_pod_reloader" {
  default     = false
  type        = bool
  description = "Enable pod reloader for cluster"
}

variable "enable_external_secrets" {
  default     = false
  type        = bool
  description = "Enable external secrets for cluster"
}

variable "enable_external_dns" {
  default     = false
  type        = bool
  description = "Enable external dns for cluster"
}

variable "external_dns_repository" {
  description = "Helm repository for external-dns"
  type        = string
  default     = "https://charts.bitnami.com/bitnami"
}

variable "external_dns_version" {
  default     = "6.17.0" 
  type        = string
  description = "External DNS Version"
}

variable "external_secrets_version" {
  default     = "0.12.1"
  type        = string
  description = "External Secrets Version"
}

variable "tags" {
  description = "(Optional) Map of key-value pairs to associate with the resource."
  type        = map(string)
  default     = {}
}
variable "enable_velero" {
  default     = true
  type        = bool
  description = "Enable the velero addon with default values"
}

variable "velero_version" {
  default     = "8.0.0"
  type        = string
  description = "Velero helm chart version"
}

variable "velero_disable_frequent" {
  default     = false
  type        = bool
  description = "Velero disable frequent"
}

variable "velero_disable_longterm" {
  default     = false
  type        = bool
  description = "Velero disable longterm"
}

variable "velero_frequent_schedule" {
  default     = "* */8 * * *"
  type        = string
  description = "Velero schedule for frequent backup"
}

variable "velero_longterm_schedule" {
  default     = "0 1 * * *"
  type        = string
  description = "Velero schedule for longterm backups"
}

variable "velero_helm_values" {
  default     = null
  type        = map(any)
  description = "Velero helm values"
}

variable "velero_s3_bucket_name" {
  default     = null
  type        = string
  description = "Velero backup bucket"
}

variable "velero_create_bucket" {
  default     = true
  type        = bool
  description = "Create S3 bucket for velero by default"
}

variable "enable_metacontroller" {
  default     = false
  type        = bool
  description = "Enable the meta controller addon."
}

variable "metacontroller_helm_version" {
  default     = "4.11.8"
  type        = string
  description = "Metacontroller helm chart version"
}

variable "node_group_labels" {
  description = "Key-value map of Kubernetes labels. Only labels that are applied with the EKS API are managed by this argument. Other Kubernetes labels applied to the EKS Node Group will not be managed"
  type        = map(string)
  default     = null
}

variable "eks_pod_subnets" {
  description = "Map of AZ to pod subnet IDs for custom networking"
  type        = map(string)
  default     = {}
}

variable "enable_custom_rbac" {
  description = "If true, create custom cluster roles and bindings"
  type        = bool
  default     = false
}

variable "rbac_map_namespaced_role_bindings" {
  description = "Map of namespaced role bindings to create"
  type = map(object({
    roleRef = object({
      kind = string
      name = string
    })
    subject = object({
      kind = string
      name = string
    })
    namespace = string
  }))
  default = {}
}

variable "rbac_map_cluster_roles" {
  description = "Map of cluster roles to create"
  type = map(object({
    apiGroups = list(string)
    resources = list(string)
    verbs     = list(string)
  }))
  default = {}
}

variable "rbac_map_cluster_role_bindings" {
  description = "Map of cluster role bindings to create"
  type = map(object({
    roleRef = object({
      kind = string
      name = string
    })
    subject = object({
      kind = string
      name = string
    })
  }))
  default = {}
}

variable "node_security_group_tags" {
  description = "A map of additional tags to add to the node security group created"
  type        = map(string)
  default     = {}
}

variable "aws_route53_zone" {
  description = "the hosted route53 zone"
  type = string
  default = null
}

variable "istio_ingresses" {
  description = "Map of Istio ingress definitions. If empty, the default ingress is used."
  type = map(object({
    name                          = string
    alb_ssl_redirect              = string
    alb_certificate_arn           = string
    alb_listen_port               = string
    alb_scheme                    = string
    alb_tls_policy                = string
    alb_additional_security_group = list(string)
    alb_waf_arn                   = string
    ingress_class_name            = string
  }))
  default = {}
}

variable "nginx_ingresses" {
  description = "Map of NGINX ALB ingress configurations"
  type = map(object({
    name                          = string
    alb_ssl_redirect              = string
    alb_certificate_arn           = string
    alb_listen_port               = string
    alb_scheme                    = string
    alb_tls_policy                = string
    alb_additional_security_group = list(string)
    alb_waf_arn                   = string
  }))
  default = {}
}
variable "enable_otel" {
  description = "Whether to install otel splunk"
  type        = bool
  default     = false
}

variable "otel_version" {
  default     = "0.126.0"
  type        = string
  description = "Otel Splunk helm chart version"
}
variable "otel_app_namespace" {
  description = "Splunk OTD app namespace"
  type        = string
  default     = ""

}

variable "workload_namespaces" {
  description = "List of namespaces to create for workloads"
  type        = list(string)
  default     = []
}

variable "workload_namespace_labels_map" {
  description = "Map of namespace name to label maps for workload namespaces"
  type        = map(map(string))
  default     = {}
}

variable "external_dns_txt_prefix" {
  description = "Prefix for external-dns TXT records"
  type        = string
  default     = ""   
}

variable "aws_region" {
  description = "The AWS region for external-dns"
  type        = string
  default     = "us-east-1"
}