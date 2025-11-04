variable "cluster_name" {
  description = "Cluster Name"
  type        = string
}

variable "cluster_version" {
  description = "Kuberentes Version"
  type        = string
}

variable "enable_karpenter" {
  default     = false
  description = "Enable karpenter"
  type        = string
}

variable "enable_karpenter_custom_resource" {
  default     = false
  description = "Enable karpenter"
  type        = string
}

variable "enable_karpenter_iam" {
  default     = "true"
  description = "If 'true', create the Karpenter Node IAM resources"
  type        = string
}

variable "karpenter_version" {
  default     = "v0.32.1"
  description = "Karpenter Version"
  type        = string
}

variable "karpenter_node_policies" {
  default = [
    "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController",
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
  description = "Karpenter node role policies"
  type        = list(string)
}

variable "node_group_subnets" {
  description = "List of node subnet identifiers. Recommended to use local subnets"
  type        = set(string)
}

variable "karpenter_instance_category" {
  default     = ["m"]
  type        = set(string)
  description = "Instance category for karpenter nodes"
}

variable "karpenter_instance_generation" {
  default     = ["5"]
  type        = set(string)
  description = "Instance generation for karpenter nodes"
}

variable "karpenter_instance_cpu" {
  default     = ["4"]
  type        = set(string)
  description = "Instance CPU for karpenter nodes"
}

variable "karpenter_node_class" {
  default     = "default"
  type        = string
  description = "Node Class Name for Karpenter"
}

variable "karpenter_capacity_type" {
  default     = ["on-demand"]
  type        = set(string)
  description = "Capacity Type for karpenter node"
}

variable "tags" {
  description = "(Optional) Map of key-value pairs to associate with the resource."
  type        = map(string)
  default     = {}
}

variable "app_id" {
  description = "Official AppID obtained via Cherwell ticket."
  type        = string
}

variable "cost_code" {
  description = "10 digit Identifier for financial tracking and budgeting."
  type        = string
}

variable "app_ref_id" {
  type        = string
}

variable "enable_karpenter_accessentry" {
  default     = "true"
  description = "If 'true', create the Karpenter Node IAM resources"
  type        = string
}


variable "override_values" {
  type        = map(map(any))
  description = "Merged environment-specific Helm values for all charts"
  default     = {}
}

variable "enable_node_local_dns" {
  type    = bool
  default = false
  description = "Controls whether to deploy the node-local-dns addon."
}

variable "node_local_dns_helm_config" {
  type = object({
    name             = string
    chart            = string
    repository       = string
    version          = string
    namespace        = string
    create_namespace = bool
    timeout          = number
    values           = list(string)
    # Add any other standard helm_release arguments here if needed
  })
  description = <<EOT
Base Helm config for node-local-dns.
The default in locals can be overridden by consumers.
EOT
  default = null
}

variable "poller_interval_ms" {
  type        = number
  description = "Interval in milliseconds for the poller to check for changes in the cluster"
  default     = 3000
}

variable "node_local_dns_chart_version" {
  description = "Version of the node-local-dns Helm chart"
  type        = string
  default     = "1.3.2"
}

variable "enable_cluster_proportional_autoscaler" {
  default     = false
  description = "Enable karpenter"
  type        = string
}

variable "cluster_proportional_autoscaler_chart_version" {
  description = "Version of the node-local-dns Helm chart"
  type        = string
  default     = "1.0.1"
}

variable "cluster_proportional_autoscaler_config" {
  type = object({
    name             = string
    chart            = string
    repository       = string
    version          = string
    namespace        = string
    create_namespace = bool
    timeout          = number
    values           = list(string)
    # Add any other standard helm_release arguments here if needed
  })
  description = <<EOT
Base Helm config for node-local-dns.
The default in locals can be overridden by consumers.
EOT
  default = null
}

variable "telepresence_chart_version" {
  description = "Version of the telepresence Helm chart"
  type        = string
  default     = "2.12.1"
}

variable "telepresence_install_namespace" {
  description = "Namespace where Telepresence will be installed"
  type        = string
  default     = "ambassador"
}

variable "enable_telepresence" {
  description = "Enable Telepresence installation"
  type        = bool
  default     = false
}

variable "telepresence_helm_config" {
  description = "Helm configuration for Telepresence installation"
  type        = any
  default     = null
}

variable "enable_argo_rollouts" {
  description = "Enable or disable deployment of Argo Rollouts"
  type        = bool
  default     = true
}

variable "argo_rollouts_install_namespace" {
  description = "Namespace for Argo Rollouts"
  type        = string
  default     = "argo-rollouts"
}

variable "argo_rollouts_chart_version" {
  description = "Argo Rollouts Helm chart version"
  type        = string
  default     = "2.36.0"
}

variable "argo_rollouts_helm_config" {
  description = "Additional Helm values for Argo Rollouts"
  type        = map(any)
  default     = {}
}

variable "custom_helm_releases" {
  description = "Helm releases to deploy to the EKS Cluster"
  type        = any
  default     = {}
}