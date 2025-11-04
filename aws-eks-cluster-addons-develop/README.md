# aws-eks-cluster-addons

## Addons

Karpenter
Node-local-dns
Argo-rollouts
Telepresence
Cluster-proportional-autoscaler

<!-- BEGIN_TF_DOCS -->

#### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_id"></a> [app_id](#input_app_id) | Official AppID obtained via Cherwell ticket. | `string` | n/a | yes |
| <a name="input_app_ref_id"></a> [app_ref_id](#input_app_ref_id) | n/a | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster_name](#input_cluster_name) | Cluster Name | `string` | n/a | yes |
| <a name="input_cluster_version"></a> [cluster_version](#input_cluster_version) | Kuberentes Version | `string` | n/a | yes |
| <a name="input_cost_code"></a> [cost_code](#input_cost_code) | 10 digit Identifier for financial tracking and budgeting. | `string` | n/a | yes |
| <a name="input_node_group_subnets"></a> [node_group_subnets](#input_node_group_subnets) | List of node subnet identifiers. Recommended to use local subnets | `set(string)` | n/a | yes |
| <a name="input_enable_karpenter"></a> [enable_karpenter](#input_enable_karpenter) | Enable karpenter | `string` | `false` | no |
| <a name="input_enable_karpenter_accessentry"></a> [enable_karpenter_accessentry](#input_enable_karpenter_accessentry) | If 'true', create the Karpenter Node IAM resources | `string` | `"true"` | no |
| <a name="input_enable_karpenter_custom_resource"></a> [enable_karpenter_custom_resource](#input_enable_karpenter_custom_resource) | Enable karpenter | `string` | `false` | no |
| <a name="input_enable_karpenter_iam"></a> [enable_karpenter_iam](#input_enable_karpenter_iam) | If 'true', create the Karpenter Node IAM resources | `string` | `"true"` | no |
| <a name="input_karpenter_capacity_type"></a> [karpenter_capacity_type](#input_karpenter_capacity_type) | Capacity Type for karpenter node | `set(string)` | `[ "on-demand" ]` | no |
| <a name="input_karpenter_instance_category"></a> [karpenter_instance_category](#input_karpenter_instance_category) | Instance category for karpenter nodes | `set(string)` | `[ "m" ]` | no |
| <a name="input_karpenter_instance_cpu"></a> [karpenter_instance_cpu](#input_karpenter_instance_cpu) | Instance CPU for karpenter nodes | `set(string)` | `[ "4" ]` | no |
| <a name="input_karpenter_instance_generation"></a> [karpenter_instance_generation](#input_karpenter_instance_generation) | Instance generation for karpenter nodes | `set(string)` | `[ "5" ]` | no |
| <a name="input_karpenter_node_class"></a> [karpenter_node_class](#input_karpenter_node_class) | Node Class Name for Karpenter | `string` | `"default"` | no |
| <a name="input_karpenter_node_policies"></a> [karpenter_node_policies](#input_karpenter_node_policies) | Karpenter node role policies | `list(string)` | `[ "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy", "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly", "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy", "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController", "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy", "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore" ]` | no |
| <a name="input_karpenter_version"></a> [karpenter_version](#input_karpenter_version) | Karpenter Version | `string` | `"v0.32.1"` | no |
| <a name="input_tags"></a> [tags](#input_tags) | (Optional) Map of key-value pairs to associate with the resource. | `map(string)` | `{}` | no |
| <a name="input_custom_helm_releases"></a> [custom_helm_releases](#input_custom_helm_releases) | (Optional) Map of key-value pairs to create custom helm resources | `map(any)` | `{}` | no |
| <a name="input_override_values"></a> [override_values](#input_override_values) | Merged environment-specific Helm values for all charts | `map(map(any))` | `{}` | no |
| <a name="input_enable_node_local_dns"></a> [enable_node_local_dns](#input_enable_node_local_dns) | Controls whether to deploy the node-local-dns addon. | `bool` | `false` | no |
| <a name="input_node_local_dns_helm_config"></a> [node_local_dns_helm_config](#input_node_local_dns_helm_config) | Base Helm config for node-local-dns. The default in locals can be overridden by consumers. | <pre>object({<br>  name             = string<br>  chart            = string<br>  repository       = string<br>  version          = string<br>  namespace        = string<br>  create_namespace = bool<br>  timeout          = number<br>  values           = list(string)<br>})</pre> | `null` | no |
| <a name="input_poller_interval_ms"></a> [poller_interval_ms](#input_poller_interval_ms) | Interval in milliseconds for the poller to check for changes in the cluster | `number` | `3000` | no |
| <a name="input_node_local_dns_chart_version"></a> [node_local_dns_chart_version](#input_node_local_dns_chart_version) | Version of the node-local-dns Helm chart | `string` | `"1.3.2"` | no |
| <a name="input_enable_cluster_proportional_autoscaler"></a> [enable_cluster_proportional_autoscaler](#input_enable_cluster_proportional_autoscaler) | Enable karpenter | `string` | `false` | no |
| <a name="input_cluster_proportional_autoscaler_chart_version"></a> [cluster_proportional_autoscaler_chart_version](#input_cluster_proportional_autoscaler_chart_version) | Version of the node-local-dns Helm chart | `string` | `"1.0.1"` | no |
| <a name="input_cluster_proportional_autoscaler_config"></a> [cluster_proportional_autoscaler_config](#input_cluster_proportional_autoscaler_config) | Base Helm config for node-local-dns. The default in locals can be overridden by consumers. | <pre>object({<br>  name             = string<br>  chart            = string<br>  repository       = string<br>  version          = string<br>  namespace        = string<br>  create_namespace = bool<br>  timeout          = number<br>  values           = list(string)<br>})</pre> | `null` | no |
| <a name="input_telepresence_chart_version"></a> [telepresence_chart_version](#input_telepresence_chart_version) | Version of the telepresence Helm chart | `string` | `"2.12.1"` | no |
| <a name="input_telepresence_install_namespace"></a> [telepresence_install_namespace](#input_telepresence_install_namespace) | Namespace where Telepresence will be installed | `string` | `"ambassador"` | no |
| <a name="input_enable_telepresence"></a> [enable_telepresence](#input_enable_telepresence) | Enable Telepresence installation | `bool` | `false` | no |
| <a name="input_telepresence_helm_config"></a> [telepresence_helm_config](#input_telepresence_helm_config) | Helm configuration for Telepresence installation | `any` | `null` | no |
| <a name="input_enable_argo_rollouts"></a> [enable_argo_rollouts](#input_enable_argo_rollouts) | Enable or disable deployment of Argo Rollouts | `bool` | `true` | no |
| <a name="input_argo_rollouts_install_namespace"></a> [argo_rollouts_install_namespace](#input_argo_rollouts_install_namespace) | Namespace for Argo Rollouts | `string` | `"argo-rollouts"` | no |
| <a name="input_argo_rollouts_chart_version"></a> [argo_rollouts_chart_version](#input_argo_rollouts_chart_version) | Argo Rollouts Helm chart version | `string` | `"2.36.0"` | no |
| <a name="input_argo_rollouts_helm_config"></a> [argo_rollouts_helm_config](#input_argo_rollouts_helm_config) | Additional Helm values for Argo Rollouts | `map(any)` | `{}` | no |
| <a name="input_custom_helm_releases"></a> [custom_helm_releases](#input_custom_helm_releases) | Helm releases to deploy to the EKS Cluster | `any` | `{}` | no |

#### Resources

| Name | Type |
|------|------|
| [aws_eks_access_entry.node-access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_access_entry) | resource |
| [aws_eks_access_entry.node-controller-access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_access_entry) | resource |
| [aws_iam_instance_profile.karpenter_node_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.karpenter_controller_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.node_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.karpenter_controller_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.karpenter_node_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.controller-role-attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.node-role-attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.role-policy-attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [helm_release.karpenter](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.karpenter-crd](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_manifest.nodeclass](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.nodegroup](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [helm_release.custom_release](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_ecrpublic_authorization_token.ecr_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecrpublic_authorization_token) | data source |
| [aws_eks_cluster.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [helm_release.node_local_dns](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.telepresence](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.cluster_proportional_autoscaler](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.argo_rollouts](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

<!-- END_TF_DOCS -->
