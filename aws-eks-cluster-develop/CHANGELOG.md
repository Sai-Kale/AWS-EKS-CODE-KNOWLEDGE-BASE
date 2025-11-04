# CHANGELOG

[[_TOC_]]

## 08-27-2025

- Fixed cluster autoscaler

## 08/04/2025

- Added external-dns addon.

## 7/31/2025

- Updated the default value of `ami_type` variable to `"AL2023_x86_64_STANDARD"`.
- Modified the `aws_ami.eks_default_ami` data source to filter for AMIs with names matching `charter_eks_${var.cluster_version}_al2023_x86_64_ami_*` for AL2023 support.

## 7/24/2025

- Added fluentd_helm_values variable to allow overriding of the values that we pass to fluentd
- Added pod_reloader_helm_values variable to allow overriding of the values that we pass to pod reloader
- Added workload_namespaces and workload_namespace_labels_map variables to provide option for consumer modules to pass the namespace and label values for workload namespaces.
- updated datadog variable type to any

## 07/09/2025

- HOTFIX - allow users to only input datadog api key

## 06/20/2025

- HOTFIX - locking down aws and helm terraform providers due to breaking changes in their upgrades

## 06/16/2025

- BREAKING CHANGE: Allow support for multiple ALBs
- Fix: cluster-autoscaler roles
- Fix: isito helm chart version
- Feature: add support for otel splunk

## 05/21/2025

- Added node_security_group_tags variable that we can use to apply tags to eks node scurity groups to use that for karpenter nodes, these tags help karpenter controller discover the security group.

## 05/08/2025

- Feature: Added kubectl_manifest resource in addons.tf to create ENIConfig resources for custom networking.
- Feature: Added custom-rbac.tf to manage custom RBAC roles and bindings to map to access entries
- Minor adjustments to outputs.tf and main.tf for compatibility with the new features.

## 2/12/2025
- BREAKING CHANGE: Update required tags and remove AMI artifactory credentials (version 2.0.0)
- Feature: Add support for node labels
- Feature: Add support for metacontroller
- Feature: Update mirror terraform version
- Feature: Update default datadog chart version
- Fix: Update default falcon chart versions
- Fix: Remove unused variables and data block
- Fix: Pull all available add-on images from artifactory

## 1/29/25

Fix: Added docker-artifactory secrets to the addons namespaces

Fix: force_update_version for mirrored EKS module to fix issues where pod distrupion budgets interfere with EKS upgrades

## 12/13/24
Add Contrast Agent Operator

## 11/12/24
Added required variables used for tagging AWS resources for ownership and budget tracking:
- app_id
- cost_code
- owner
- team
- app
- data_priv
- group
- vp
- org
- ops_owner
- sec_owner
- dev_owner
