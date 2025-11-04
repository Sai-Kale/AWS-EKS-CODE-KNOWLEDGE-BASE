# AWS EKS

[[_TOC_]]

## ⚠️ Important Upgrade Notice for Version 3.0.0

**Warning:** Upgrading from any previous 2.x.x version to 3.0.0 will cause the Application Load Balancer (ALB) to be rebuilt and assigned a new ALB address. Be sure to update any references to the previous ALB address after upgrading.

## ⚠️ Important Upgrade Notice for Version 2.x.x

**Warning:** Upgrading to version 2.x.x of this Terraform module requires special attention.

- Direct upgrades from previous versions to 2.x.x are not supported.
- The upgrade process involves the following steps:
  1. Destroy all resources managed by the previous version of this module.
  2. Update your Terraform configuration to use version 2.x.x.
  3. Rebuild your infrastructure using the new version.

## Contrast
You can retrieve the contrast credentials from https://app.contrastsecurity.com/. The login credential should change to ESSO after you put in your charter email.

## Common Issues

### 1. Finding too many additional roles to be added to cluster access.
Default for adding runners access is expecting only 1 platform and 1 k8s runner. If you have multiple, this error might show up
```terraform
Error: Invalid function argument
│
│   on .terraform/modules/eks-cluster/locals.tf line 4, in locals:
│    4:   additional_roles   = [for k, v in {for key, value in data.aws_iam_roles.additional_roles : key => one(value["arns"]) if one(value["arns"]) != null} : v]
│     ├────────────────
│     │ value["arns"] is set of string with 2 elements
│
│ Invalid value for "list" parameter: must be a list, set, or tuple value with either zero or one elements.
```
#### Solution
Update the `additional_admin_role_regex` to be more specific to your runner and other roles. If you want additional runner/roles just add another that is more specific instead of trying to match multiple. Defaults are
```terraform
additional_admin_role_regex = [".*_k8s_runner_instance_role", ".*_platform_runner_role"]
```

## Resources
<!-- BEGIN_TF_DOCS -->
#### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster_name](#input_cluster_name) | Name of the EKS cluster | `string` | n/a | yes |
| <a name="input_cluster_version"></a> [cluster_version](#input_cluster_version) | K8s version of the cluster | `string` | n/a | yes |
| <a name="input_control_plane_subnets"></a> [control_plane_subnets](#input_control_plane_subnets) | Subnet IDs where EKS worker nodes will be created. Recommended private subnets | `set(string)` | n/a | yes |
| <a name="input_credentials"></a> [credentials](#input_credentials) | Map of credentials with provider config. Must have artifactory_username, artifactory_password, datadog_api_key | ```list(object({ name = string provider = optional(string, "ssm") path = string }))``` | n/a | yes |
| <a name="input_falcon_cid"></a> [falcon_cid](#input_falcon_cid) | Falcon CID | `string` | n/a | yes |
| <a name="input_falcon_client"></a> [falcon_client](#input_falcon_client) | Falcon Client | `string` | n/a | yes |
| <a name="input_falcon_secret"></a> [falcon_secret](#input_falcon_secret) | Falcon Secret | `string` | n/a | yes |
| <a name="input_node_group_subnets"></a> [node_group_subnets](#input_node_group_subnets) | List of node subnet identifiers. Recommended to use local subnets | `set(string)` | n/a | yes |
| <a name="input_access_entries"></a> [access_entries](#input_access_entries) | Map of access entries to add to the cluster | ```map(object({ principal_arn = string kubernetes_groups = optional(list(string), []) policy_associations = map(object({ policy_arn = string access_scope = object({ namespaces = list(string) type = string }) })) }))``` | `{}` | no |
| <a name="input_additional_admin_role_regex"></a> [additional_admin_role_regex](#input_additional_admin_role_regex) | Additional regex of aws roles to be used to for cluster access | `set(string)` | ```[ ".*_k8s_runner_instance_role", ".*_platform_runner_role" ]``` | no |
| <a name="input_admin_role_regex"></a> [admin_role_regex](#input_admin_role_regex) | Cloud Admin regex name to be used to find SSO admin role for cluster access | `string` | `"AWSReservedSSO_CloudAdministratorAccess*"` | no |
| <a name="input_alb_additional_security_group"></a> [alb_additional_security_group](#input_alb_additional_security_group) | List of additional, externally created security group IDs to attach to the alb | `set(string)` | `[]` | no |
| <a name="input_alb_certificate_arn"></a> [alb_certificate_arn](#input_alb_certificate_arn) | AWS Certificate arn | `string` | `null` | no |
| <a name="input_alb_controller_version"></a> [alb_controller_version](#input_alb_controller_version) | ALB Controller Vrsion | `string` | `"1.8.1"` | no |
| <a name="input_alb_internal"></a> [alb_internal](#input_alb_internal) | If alb is internal | `bool` | `false` | no |
| <a name="input_alb_tls_policy"></a> [alb_tls_policy](#input_alb_tls_policy) | ALB TLS policy | `string` | `"ELBSecurityPolicy-TLS-1-2-Ext-2018-06"` | no |
| <a name="input_alb_waf_arn"></a> [alb_waf_arn](#input_alb_waf_arn) | Waf arn to be added to the ALB | `string` | `null` | no |
| <a name="input_ami_id"></a> [ami_id](#input_ami_id) | Node AMI Id | `string` | `null` | no |
| <a name="input_ami_type"></a> [ami_type](#input_ami_type) | Type of Amazon Machine Image (AMI) associated with the EKS Node Group. See the [AWS documentation](https://docs.aws.amazon.com/eks/latest/APIReference/API_Nodegroup.html#AmazonEKS-Type-Nodegroup-amiType) for valid values | `string` | `"AL2023_x86_64_STANDARD"` | no |
| <a name="input_automatic_ami_update_enabled"></a> [automatic_ami_update_enabled](#input_automatic_ami_update_enabled) | Enable automatic AMI updates for the EKS node group | `bool` | `true` | no |
| <a name="input_bootstrap_extra_args"></a> [bootstrap_extra_args](#input_bootstrap_extra_args) | Bootstrap extra args | `string` | `""` | no |
| <a name="input_capacity_type"></a> [capacity_type](#input_capacity_type) | Capacity type of nodes of k8s cluster | `string` | `"ON_DEMAND"` | no |
| <a name="input_cert_manager_version"></a> [cert_manager_version](#input_cert_manager_version) | cert manager chart version | `string` | `"v1.16.3"` | no |
| <a name="input_cloudwatch_log_group_retention_in_days"></a> [cloudwatch_log_group_retention_in_days](#input_cloudwatch_log_group_retention_in_days) | Number of days to retain log events. Default retention - 90 days | `number` | `120` | no |
| <a name="input_cluster_additional_security_group_ids"></a> [cluster_additional_security_group_ids](#input_cluster_additional_security_group_ids) | List of additional, externally created security group IDs to attach to the cluster control plane | `list(string)` | `[]` | no |
| <a name="input_cluster_addons"></a> [cluster_addons](#input_cluster_addons) | Map of addon configurations for cluster addons (vpc-cni, coredns, kube-proxy) | `any` | `{}` | no |
| <a name="input_cluster_autoscaler_helm_values"></a> [cluster_autoscaler_helm_values](#input_cluster_autoscaler_helm_values) | Cluster Autoscaler helm values | `map(any)` | `null` | no |
| <a name="input_cluster_autoscaler_version"></a> [cluster_autoscaler_version](#input_cluster_autoscaler_version) | Cluster Autoscaler Version | `string` | `"9.37.0"` | no |
| <a name="input_cluster_enabled_log_types"></a> [cluster_enabled_log_types](#input_cluster_enabled_log_types) | A list of the desired control plane logs to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html) | `list(string)` | ```[ "api", "audit", "authenticator", "controllerManager", "scheduler" ]``` | no |
| <a name="input_cluster_endpoint_private_access"></a> [cluster_endpoint_private_access](#input_cluster_endpoint_private_access) | Indicates whether or not the Amazon EKS private API server endpoint is enabled | `bool` | `true` | no |
| <a name="input_cluster_endpoint_public_access"></a> [cluster_endpoint_public_access](#input_cluster_endpoint_public_access) | Indicates whether or not the Amazon EKS public API server endpoint is enabled | `bool` | `true` | no |
| <a name="input_cluster_endpoint_public_access_cidrs"></a> [cluster_endpoint_public_access_cidrs](#input_cluster_endpoint_public_access_cidrs) | List of CIDR blocks which can access the Amazon EKS public API server endpoint | `list(string)` | ```[ "142.136.0.0/21" ]``` | no |
| <a name="input_cluster_ip_family"></a> [cluster_ip_family](#input_cluster_ip_family) | The IP family used to assign Kubernetes pod and service addresses. Valid values are `ipv4` (default) and `ipv6`. You can only specify an IP family when you create a cluster, changing this value will force a new cluster to be created | `string` | `"ipv4"` | no |
| <a name="input_cluster_kms_key_deletion_window_in_days"></a> [cluster_kms_key_deletion_window_in_days](#input_cluster_kms_key_deletion_window_in_days) | The waiting period, specified in number of days. After the waiting period ends, AWS KMS deletes the KMS key. If you specify a value, it must be between `7` and `30`, inclusive. If you do not specify a value, it defaults to `30` | `number` | `30` | no |
| <a name="input_cluster_security_group_additional_rules"></a> [cluster_security_group_additional_rules](#input_cluster_security_group_additional_rules) | List of additional security group rules to add to the cluster security group created. Set `source_node_security_group = true` inside rules to set the `node_security_group` as source | ```map(object({ description = string protocol = string from_port = number to_port = number type = string cidr_blocks = list(string) source_security_group_id = string }))``` | `{}` | no |
| <a name="input_cluster_security_group_id"></a> [cluster_security_group_id](#input_cluster_security_group_id) | Existing security group ID to be attached to the cluster | `string` | `""` | no |
| <a name="input_contrast_agent_environment"></a> [contrast_agent_environment](#input_contrast_agent_environment) | Contrast Agent operator environment. DEVELOPMENT, QA, PROD | `string` | `"DEVELOPMENT"` | no |
| <a name="input_contrast_agent_operator_version"></a> [contrast_agent_operator_version](#input_contrast_agent_operator_version) | Contrast Agent operator Version | `string` | `"1.5.4"` | no |
| <a name="input_create_alb"></a> [create_alb](#input_create_alb) | Variable to create the actual ALB | `bool` | `true` | no |
| <a name="input_create_cloudwatch_log_group"></a> [create_cloudwatch_log_group](#input_create_cloudwatch_log_group) | Determines whether a log group is created by this module for the cluster logs. If not, AWS will automatically create one if logging is enabled | `bool` | `false` | no |
| <a name="input_create_cluster_security_group"></a> [create_cluster_security_group](#input_create_cluster_security_group) | Determines if a security group is created for the cluster. Note: the EKS service creates a primary security group for the cluster by default | `bool` | `true` | no |
| <a name="input_create_cni_ipv6_iam_policy"></a> [create_cni_ipv6_iam_policy](#input_create_cni_ipv6_iam_policy) | Determines whether to create an [`AmazonEKS_CNI_IPv6_Policy`](https://docs.aws.amazon.com/eks/latest/userguide/cni-iam-role.html#cni-iam-role-create-ipv6-policy) | `bool` | `false` | no |
| <a name="input_create_iam_role"></a> [create_iam_role](#input_create_iam_role) | Determines whether a an IAM role is created or to use an existing IAM role | `bool` | `true` | no |
| <a name="input_create_launch_template"></a> [create_launch_template](#input_create_launch_template) | Determines if the launch template to be created for the EKS cluster | `bool` | `true` | no |
| <a name="input_create_node_security_group"></a> [create_node_security_group](#input_create_node_security_group) | Determines whether to create a security group for the node groups or use the existing `node_security_group_id` | `bool` | `true` | no |
| <a name="input_datadog_helm_values"></a> [datadog_helm_values](#input_datadog_helm_values) | Datadog helm values | `any` | `null` | no |
| <a name="input_datadog_version"></a> [datadog_version](#input_datadog_version) | Datadog Version | `string` | `"3.89.0"` | no |
| <a name="input_desired_size"></a> [desired_size](#input_desired_size) | Desired number of nodes of k8s cluster | `number` | `1` | no |
| <a name="input_disk_size"></a> [disk_size](#input_disk_size) | Disk size of nodes of k8s cluster | `number` | `100` | no |
| <a name="input_eks_pod_subnets"></a> [eks_pod_subnets](#input_eks_pod_subnets) | Map of AZ to pod subnet IDs for custom networking | `map(string)` | `{}` | no |
| <a name="input_enable_amazon_eks_vpc_cni_custom_networking"></a> [enable_amazon_eks_vpc_cni_custom_networking](#input_enable_amazon_eks_vpc_cni_custom_networking) | Enable VPC Custom Networking | `bool` | `false` | no |
| <a name="input_enable_bootstrap_user_data"></a> [enable_bootstrap_user_data](#input_enable_bootstrap_user_data) | Determines if the user data for bootstrapping the cluster is to be enabled | `bool` | `true` | no |
| <a name="input_enable_cert_manager"></a> [enable_cert_manager](#input_enable_cert_manager) | Enable cert manager for cluster | `bool` | `false` | no |
| <a name="input_enable_cluster_autoscaler"></a> [enable_cluster_autoscaler](#input_enable_cluster_autoscaler) | Enable cluster autoscaler | `bool` | `true` | no |
| <a name="input_enable_cluster_creator_admin_permissions"></a> [enable_cluster_creator_admin_permissions](#input_enable_cluster_creator_admin_permissions) | Indicates whether or not to add the cluster creator (the identity used by Terraform) as an administrator via access entry | `bool` | `false` | no |
| <a name="input_enable_contrast_agent"></a> [enable_contrast_agent](#input_enable_contrast_agent) | Enable the Contrast Agent addon with default values. Note: Contrast Agent is required for SDIT Applications. | `bool` | `true` | no |
| <a name="input_enable_custom_rbac"></a> [enable_custom_rbac](#input_enable_custom_rbac) | If true, create custom cluster roles and bindings | `bool` | `false` | no |
| <a name="input_enable_external_secrets"></a> [enable_external_secrets](#input_enable_external_secrets) | Enable external secrets for cluster | `bool` | `false` | no |
| <a name="input_enable_irsa"></a> [enable_irsa](#input_enable_irsa) | Determines whether to create an OpenID Connect Provider for EKS to enable IRSA | `bool` | `true` | no |
| <a name="input_enable_istio"></a> [enable_istio](#input_enable_istio) | Enable istio for cluster | `bool` | `true` | no |
| <a name="input_enable_metacontroller"></a> [enable_metacontroller](#input_enable_metacontroller) | Enable the meta controller addon. | `bool` | `false` | no |
| <a name="input_enable_nginx"></a> [enable_nginx](#input_enable_nginx) | Enable nginx ingress for cluster | `bool` | `false` | no |
| <a name="input_enable_otel"></a> [enable_otel](#input_enable_otel) | Whether to install otel splunk | `bool` | `false` | no |
| <a name="input_enable_pod_reloader"></a> [enable_pod_reloader](#input_enable_pod_reloader) | Enable pod reloader for cluster | `bool` | `false` | no |
| <a name="input_enable_velero"></a> [enable_velero](#input_enable_velero) | Enable the velero addon with default values | `bool` | `true` | no |
| <a name="input_external_secrets_version"></a> [external_secrets_version](#input_external_secrets_version) | External Secrets Version | `string` | `"0.12.1"` | no |
| <a name="input_falcon_iar_chart_version"></a> [falcon_iar_chart_version](#input_falcon_iar_chart_version) | Falcon Image Analyzer Chart Version | `string` | `"1.1.8"` | no |
| <a name="input_falcon_iar_image_tag"></a> [falcon_iar_image_tag](#input_falcon_iar_image_tag) | Falcon Image Analyzer docker image Version | `string` | `"1.0.16"` | no |
| <a name="input_falcon_kac_chart_version"></a> [falcon_kac_chart_version](#input_falcon_kac_chart_version) | Falcon KAC helm version | `string` | `"1.2.0"` | no |
| <a name="input_falcon_kac_image_tag"></a> [falcon_kac_image_tag](#input_falcon_kac_image_tag) | Falcon KAC Docker Image Tag | `string` | `"7.21.0-1904.container.x86_64.Release.US-2"` | no |
| <a name="input_falcon_proxy_url"></a> [falcon_proxy_url](#input_falcon_proxy_url) | Falcon proxy URL | `string` | `"https://crowdstrike-squid-proxy-svc.meta.spectrum.net:3128"` | no |
| <a name="input_fluentd_helm_values"></a> [fluentd_helm_values](#input_fluentd_helm_values) | Fluentd helm values | `any` | `null` | no |
| <a name="input_fluentd_version"></a> [fluentd_version](#input_fluentd_version) | Fluentd Version | `string` | `"1.4.7-multiline.regex.4"` | no |
| <a name="input_force_update_version"></a> [force_update_version](#input_force_update_version) | Force version update if existing pods are unable to be drained due to a pod disruption budget issue | `bool` | `true` | no |
| <a name="input_iam_role_arn"></a> [iam_role_arn](#input_iam_role_arn) | Existing IAM role ARN for the cluster. Required if `create_iam_role` is set to `false` | `string` | `null` | no |
| <a name="input_iam_role_name"></a> [iam_role_name](#input_iam_role_name) | Name to use on IAM role created | `string` | `null` | no |
| <a name="input_iam_role_path"></a> [iam_role_path](#input_iam_role_path) | Cluster IAM role path | `string` | `null` | no |
| <a name="input_ingress_name"></a> [ingress_name](#input_ingress_name) | Release name for nginx ingress | `string` | `"ingress-nginx"` | no |
| <a name="input_instance_types"></a> [instance_types](#input_instance_types) | Node instance types | `list(string)` | ```[ "m5.xlarge" ]``` | no |
| <a name="input_istio_ingresses"></a> [istio_ingresses](#input_istio_ingresses) | Map of Istio ingress definitions. If empty, the default ingress is used. | ```map(object({ name = string alb_ssl_redirect = string alb_certificate_arn = string alb_listen_port = string alb_scheme = string alb_tls_policy = string alb_additional_security_group = list(string) alb_waf_arn = string ingress_class_name = string }))``` | `{}` | no |
| <a name="input_istio_version"></a> [istio_version](#input_istio_version) | Istio Version | `string` | `"1.26.1"` | no |
| <a name="input_kms_admin_roles"></a> [kms_admin_roles](#input_kms_admin_roles) | A list of IAM ARNs for [key administrators](https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html#key-policy-default-allow-administrators). If no value is provided, the current caller identity is used to ensure at least one key admin is available | `list(string)` | `[]` | no |
| <a name="input_max_size"></a> [max_size](#input_max_size) | Maximum number of nodes of k8s cluster | `number` | `3` | no |
| <a name="input_metacontroller_helm_version"></a> [metacontroller_helm_version](#input_metacontroller_helm_version) | Metacontroller helm chart version | `string` | `"4.11.8"` | no |
| <a name="input_metric_server_version"></a> [metric_server_version](#input_metric_server_version) | Metric Server Version | `string` | `"3.8.2"` | no |
| <a name="input_min_size"></a> [min_size](#input_min_size) | Minimum number of nodes of k8s cluster | `number` | `1` | no |
| <a name="input_nginx_custom_value_file"></a> [nginx_custom_value_file](#input_nginx_custom_value_file) | Custom nginx helm values file | `string` | `""` | no |
| <a name="input_nginx_ingresses"></a> [nginx_ingresses](#input_nginx_ingresses) | Map of NGINX ALB ingress configurations | ```map(object({ name = string alb_ssl_redirect = string alb_certificate_arn = string alb_listen_port = string alb_scheme = string alb_tls_policy = string alb_additional_security_group = list(string) alb_waf_arn = string }))``` | `{}` | no |
| <a name="input_nginx_version"></a> [nginx_version](#input_nginx_version) | nginx ingress chart version | `string` | `"4.12.0"` | no |
| <a name="input_node_group_labels"></a> [node_group_labels](#input_node_group_labels) | Key-value map of Kubernetes labels. Only labels that are applied with the EKS API are managed by this argument. Other Kubernetes labels applied to the EKS Node Group will not be managed | `map(string)` | `null` | no |
| <a name="input_node_group_metadata_options"></a> [node_group_metadata_options](#input_node_group_metadata_options) | Node metadata options | ```object({ http_endpoint = optional(string) http_tokens = optional(string) http_put_response_hop_limit = optional(number) })``` | ```{ "http_endpoint": "enabled", "http_put_response_hop_limit": 2, "http_tokens": "optional" }``` | no |
| <a name="input_node_security_group_additional_rules"></a> [node_security_group_additional_rules](#input_node_security_group_additional_rules) | List of additional security group rules to add to the node security group created. Set `source_cluster_security_group = true` inside rules to set the `cluster_security_group` as source | ```map(object({ description = string protocol = string from_port = number to_port = number type = string source_cluster_security_group = optional(bool) self = optional(bool) }))``` | `{}` | no |
| <a name="input_node_security_group_tags"></a> [node_security_group_tags](#input_node_security_group_tags) | A map of additional tags to add to the node security group created | `map(string)` | `{}` | no |
| <a name="input_otel_app_namespace"></a> [otel_app_namespace](#input_otel_app_namespace) | Splunk OTD app namespace | `string` | `""` | no |
| <a name="input_otel_version"></a> [otel_version](#input_otel_version) | Otel Splunk helm chart version | `string` | `"0.126.0"` | no |
| <a name="input_pod_reloader_helm_values"></a> [pod_reloader_helm_values](#input_pod_reloader_helm_values) | pod reloader helm values | `any` | `null` | no |
| <a name="input_pod_reloader_version"></a> [pod_reloader_version](#input_pod_reloader_version) | pod reloader chart version | `string` | `"1.2.1"` | no |
| <a name="input_post_bootstrap_user_data"></a> [post_bootstrap_user_data](#input_post_bootstrap_user_data) | user data to be run after bootstrap of the EKS cluster | `string` | `""` | no |
| <a name="input_public_subnets"></a> [public_subnets](#input_public_subnets) | List of node subnet identifiers. | `set(string)` | `[]` | no |
| <a name="input_rbac_map_cluster_role_bindings"></a> [rbac_map_cluster_role_bindings](#input_rbac_map_cluster_role_bindings) | Map of cluster role bindings to create | ```map(object({ roleRef = object({ kind = string name = string }) subject = object({ kind = string name = string }) }))``` | `{}` | no |
| <a name="input_rbac_map_cluster_roles"></a> [rbac_map_cluster_roles](#input_rbac_map_cluster_roles) | Map of cluster roles to create | ```map(object({ apiGroups = list(string) resources = list(string) verbs = list(string) }))``` | `{}` | no |
| <a name="input_rbac_map_namespaced_role_bindings"></a> [rbac_map_namespaced_role_bindings](#input_rbac_map_namespaced_role_bindings) | Map of namespaced role bindings to create | ```map(object({ roleRef = object({ kind = string name = string }) subject = object({ kind = string name = string }) namespace = string }))``` | `{}` | no |
| <a name="input_splunk_host"></a> [splunk_host](#input_splunk_host) | Splunk host | `string` | `"aws-cribl-hec.tools.prd.spectrum.net"` | no |
| <a name="input_splunk_index"></a> [splunk_index](#input_splunk_index) | Splunk Index | `string` | `"aws-sa-prod"` | no |
| <a name="input_sub_admin_role_regex"></a> [sub_admin_role_regex](#input_sub_admin_role_regex) | Sub Admin regex name to be used to find SSO sub admin role for cluster access | `string` | `"AWSReservedSSO_subaccount_admins*"` | no |
| <a name="input_tags"></a> [tags](#input_tags) | (Optional) Map of key-value pairs to associate with the resource. | `map(string)` | `{}` | no |
| <a name="input_velero_create_bucket"></a> [velero_create_bucket](#input_velero_create_bucket) | Create S3 bucket for velero by default | `bool` | `true` | no |
| <a name="input_velero_disable_frequent"></a> [velero_disable_frequent](#input_velero_disable_frequent) | Velero disable frequent | `bool` | `false` | no |
| <a name="input_velero_disable_longterm"></a> [velero_disable_longterm](#input_velero_disable_longterm) | Velero disable longterm | `bool` | `false` | no |
| <a name="input_velero_frequent_schedule"></a> [velero_frequent_schedule](#input_velero_frequent_schedule) | Velero schedule for frequent backup | `string` | `"* */8 * * *"` | no |
| <a name="input_velero_helm_values"></a> [velero_helm_values](#input_velero_helm_values) | Velero helm values | `map(any)` | `null` | no |
| <a name="input_velero_longterm_schedule"></a> [velero_longterm_schedule](#input_velero_longterm_schedule) | Velero schedule for longterm backups | `string` | `"0 1 * * *"` | no |
| <a name="input_velero_s3_bucket_name"></a> [velero_s3_bucket_name](#input_velero_s3_bucket_name) | Velero backup bucket | `string` | `null` | no |
| <a name="input_velero_version"></a> [velero_version](#input_velero_version) | Velero helm chart version | `string` | `"8.0.0"` | no |
| <a name="input_volume_iops"></a> [volume_iops](#input_volume_iops) | The number of I/O operations per second (IOPS) that the volume supports | `number` | `3000` | no |
| <a name="input_volume_throughput"></a> [volume_throughput](#input_volume_throughput) | Throughput of volume in mebibytes per second (MiBps) | `number` | `150` | no |
| <a name="input_vpc_id"></a> [vpc_id](#input_vpc_id) | VPC ID | `string` | `""` | no |
| <a name="input_worker_additional_security_group_rules"></a> [worker_additional_security_group_rules](#input_worker_additional_security_group_rules) | List of SG rules to be added to the worker nodes SG | ```map(object({ protocol = string from_port = number to_port = number source_security_group_id = string }))``` | `{}` | no |
| <a name="input_worker_iam_role_additional_policies"></a> [worker_iam_role_additional_policies](#input_worker_iam_role_additional_policies) | Additional IAM policies to be attached to the worker nodes | `map(string)` | `{}` | no |
| <a name="input_workload_namespace_labels_map"></a> [workload_namespace_labels_map](#input_workload_namespace_labels_map) | Map of namespace name to label maps for workload namespaces | `map(map(string))` | `{}` | no |
| <a name="input_enable_external_dns"></a> [enable_external_dns](#input_enable_external_dns) | Enable external dns for cluster | `bool` | `false` | no |
| <a name="input_external_dns_version"></a> [external_dns_version](#input_external_dns_version) | External DNS Version | `string` | `"6.17.0"` | no |
| <a name="input_external_dns_helm_values"></a> [external_dns_helm_values](#input_external_dns_helm_values) | External DNS helm values | `map(any)` | `null` | no |
| <a name="input_external_dns_txt_prefix"></a> [external_dns_txt_prefix](#input_external_dns_txt_prefix) | Prefix for external-dns TXT records | `string` | `""` | no |
| <a name="input_aws_region"></a> [aws_region](#input_aws_region) | The AWS region for external-dns | `string` | `"us-east-1"` | no |
| <a name="input_external_dns_repository"></a> [external_dns_repository](#input_external_dns_repository) | Helm repository for external-dns | `string` | `"https://charts.bitnami.com/bitnami"` | no |
| <a name="input_workload_namespaces"></a> [workload_namespaces](#input_workload_namespaces) | List of namespaces to create for workloads | `list(string)` | `[]` | no |
#### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws-tags"></a> [aws-tags](#module_aws-tags) | gitlab.spectrumflow.net/charter/aws-tags/aws | 1.0.0 |
| <a name="module_eks"></a> [eks](#module_eks) | gitlab.spectrumflow.net/charter/tf-mirror-terraform-aws-eks/aws | 20.37.1 |
#### Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_load_balancer_hostnames"></a> [alb_load_balancer_hostnames](#output_alb_load_balancer_hostnames) | Endpoints from all Istio Ingress ALBs |
| <a name="output_aws_auth_configmap_yaml"></a> [aws_auth_configmap_yaml](#output_aws_auth_configmap_yaml) | AWS auth ConfigMap YAML generated by the EKS module |
| <a name="output_cluster_name"></a> [cluster_name](#output_cluster_name) | Amazon EKS Cluster Id |
| <a name="output_cluster_security_group_id"></a> [cluster_security_group_id](#output_cluster_security_group_id) | Cluster Security Group |
| <a name="output_eks_ami_id"></a> [eks_ami_id](#output_eks_ami_id) | AMI Node |
| <a name="output_eks_cluster_certificate_authority_data"></a> [eks_cluster_certificate_authority_data](#output_eks_cluster_certificate_authority_data) | CA cert for Cluster |
| <a name="output_eks_cluster_endpoint"></a> [eks_cluster_endpoint](#output_eks_cluster_endpoint) | Amazon EKS Cluster Endpoint |
| <a name="output_eks_cluster_id"></a> [eks_cluster_id](#output_eks_cluster_id) | Amazon EKS Cluster Id |
| <a name="output_eks_cluster_managed_node_groups"></a> [eks_cluster_managed_node_groups](#output_eks_cluster_managed_node_groups) | Cluster Node Group |
| <a name="output_eks_node_security_group_id"></a> [eks_node_security_group_id](#output_eks_node_security_group_id) | Node Security Group |
#### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | ~> 1.6 |
| <a name="requirement_aws"></a> [aws](#requirement_aws) | ~> 5.100 |
| <a name="requirement_cloudinit"></a> [cloudinit](#requirement_cloudinit) | 2.3.7 |
| <a name="requirement_helm"></a> [helm](#requirement_helm) | 3.0.2 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement_kubectl) | 1.19.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement_kubernetes) | 2.37.1 |
| <a name="requirement_null"></a> [null](#requirement_null) | 3.2.4 |
| <a name="requirement_time"></a> [time](#requirement_time) | 0.13.1 |
| <a name="requirement_tls"></a> [tls](#requirement_tls) | 4.1.0 |
#### Resources

| Name | Type |
|------|------|
| [aws_iam_policy.alb-controller-policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.velero-s3-policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.alb-controller-role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.velero-role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.alb-attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.s3-policy-attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_s3_bucket.backup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_public_access_block.block_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [helm_release.alb-controller](https://registry.terraform.io/providers/hashicorp/helm/3.0.2/docs/resources/release) | resource |
| [helm_release.cert-manager](https://registry.terraform.io/providers/hashicorp/helm/3.0.2/docs/resources/release) | resource |
| [helm_release.cluster-autoscaler](https://registry.terraform.io/providers/hashicorp/helm/3.0.2/docs/resources/release) | resource |
| [helm_release.contrast-agent-operator](https://registry.terraform.io/providers/hashicorp/helm/3.0.2/docs/resources/release) | resource |
| [helm_release.datadog](https://registry.terraform.io/providers/hashicorp/helm/3.0.2/docs/resources/release) | resource |
| [helm_release.external-secrets](https://registry.terraform.io/providers/hashicorp/helm/3.0.2/docs/resources/release) | resource |
| [helm_release.falcon-image-analyzer](https://registry.terraform.io/providers/hashicorp/helm/3.0.2/docs/resources/release) | resource |
| [helm_release.fluentd](https://registry.terraform.io/providers/hashicorp/helm/3.0.2/docs/resources/release) | resource |
| [helm_release.istio-base](https://registry.terraform.io/providers/hashicorp/helm/3.0.2/docs/resources/release) | resource |
| [helm_release.istio-ingress](https://registry.terraform.io/providers/hashicorp/helm/3.0.2/docs/resources/release) | resource |
| [helm_release.istiod](https://registry.terraform.io/providers/hashicorp/helm/3.0.2/docs/resources/release) | resource |
| [helm_release.kac](https://registry.terraform.io/providers/hashicorp/helm/3.0.2/docs/resources/release) | resource |
| [helm_release.kube-state-metrics](https://registry.terraform.io/providers/hashicorp/helm/3.0.2/docs/resources/release) | resource |
| [helm_release.metacontroller](https://registry.terraform.io/providers/hashicorp/helm/3.0.2/docs/resources/release) | resource |
| [helm_release.metrics-server](https://registry.terraform.io/providers/hashicorp/helm/3.0.2/docs/resources/release) | resource |
| [helm_release.nginx-ingress](https://registry.terraform.io/providers/hashicorp/helm/3.0.2/docs/resources/release) | resource |
| [helm_release.otel](https://registry.terraform.io/providers/hashicorp/helm/3.0.2/docs/resources/release) | resource |
| [helm_release.pod-reloader](https://registry.terraform.io/providers/hashicorp/helm/3.0.2/docs/resources/release) | resource |
| [helm_release.velero](https://registry.terraform.io/providers/hashicorp/helm/3.0.2/docs/resources/release) | resource |
| [kubectl_manifest.cluster_role_bindings](https://registry.terraform.io/providers/gavinbunney/kubectl/1.19.0/docs/resources/manifest) | resource |
| [kubectl_manifest.cluster_roles](https://registry.terraform.io/providers/gavinbunney/kubectl/1.19.0/docs/resources/manifest) | resource |
| [kubectl_manifest.default-agent-configuration](https://registry.terraform.io/providers/gavinbunney/kubectl/1.19.0/docs/resources/manifest) | resource |
| [kubectl_manifest.default-agent-connection](https://registry.terraform.io/providers/gavinbunney/kubectl/1.19.0/docs/resources/manifest) | resource |
| [kubectl_manifest.eni_config](https://registry.terraform.io/providers/gavinbunney/kubectl/1.19.0/docs/resources/manifest) | resource |
| [kubectl_manifest.namespaced_role_bindings](https://registry.terraform.io/providers/gavinbunney/kubectl/1.19.0/docs/resources/manifest) | resource |
| [kubernetes_ingress_class_v1.istio](https://registry.terraform.io/providers/hashicorp/kubernetes/2.37.1/docs/resources/ingress_class_v1) | resource |
| [kubernetes_ingress_v1.ingress](https://registry.terraform.io/providers/hashicorp/kubernetes/2.37.1/docs/resources/ingress_v1) | resource |
| [kubernetes_ingress_v1.nginx-ingress](https://registry.terraform.io/providers/hashicorp/kubernetes/2.37.1/docs/resources/ingress_v1) | resource |
| [kubernetes_namespace.addon_namespaces](https://registry.terraform.io/providers/hashicorp/kubernetes/2.37.1/docs/resources/namespace) | resource |
| [kubernetes_namespace.workloads](https://registry.terraform.io/providers/hashicorp/kubernetes/2.37.1/docs/resources/namespace) | resource |
| [kubernetes_secret.contrast-agent-secret](https://registry.terraform.io/providers/hashicorp/kubernetes/2.37.1/docs/resources/secret) | resource |
| [kubernetes_secret_v1.docker_registry_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/2.37.1/docs/resources/secret_v1) | resource |
| [aws_ami.eks_default_ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_default_tags.provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/default_tags) | data source |
| [aws_iam_roles.additional_roles](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_roles) | data source |
| [aws_iam_roles.admin_roles](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_roles) | data source |
| [aws_iam_roles.sub_admin_roles](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_roles) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_secretsmanager_secret.bootstrap_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret_version.secret_version](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |
| [aws_ssm_parameter.ssm_keys](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_subnet.eks_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnet.node_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

<!-- END_TF_DOCS -->
