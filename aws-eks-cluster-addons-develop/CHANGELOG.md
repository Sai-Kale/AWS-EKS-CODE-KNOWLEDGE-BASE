# CHANGELOG

[[_TOC_]]

## Changelog Entry - Date


## 5/21/2025

- Updated module code to support using exisitng worker nodes security group for karpenter nodes
- Add support to disable custom resources (nodepool and ec2nodeclass) that are part of this module code with a feature flag so that calling module can define those as existing code is not working because crds needs to be present on the cluster before we install custom resoruces, even depends_on was not working so i think it is better to seperate custom resource installation from crds and controller installation.

## 6/3/2025

- Added `custom_releases.tf` to manage and track custom release versions within the module, enabling more granular control over resource updates and rollbacks.
- Using tags module instead of local variable to mergee all tags together.

## 6/4/2025

- Added nodelocaldns, telepresence , argo rollouts, cluster-proportional-autoscale addons 
- Updated Karpenter Helm release to allow passing custom values to the Helm chart
- As a best practise removed privders from child modules, we can define providers in root module and required providers in child module.
  https://discuss.hashicorp.com/t/terraform-reusable-modules-and-provider-declarations-best-practices/39808/2
