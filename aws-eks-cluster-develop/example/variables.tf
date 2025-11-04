variable "cluster_name" {
  description = "Cluster Name"
  type        = string
}
variable "cluster_version" {
  type = string
}

variable "public_subnets" {
  description = "List of node subnet identifiers."
  type        = set(string)
}
variable "control_plane_subnets" {
  description = "List of node subnet identifiers."
  type        = set(string)
}
variable "node_group_subnets" {
  description = "List of node subnet identifiers."
  type        = set(string)
}

variable "credentials" {
  description = "Map of credentials with provider config"
  type        = list(object({
    name     = string
    provider = optional(string, "ssm")
    path     = string
  }))

  default = []
}
variable "min_size" {
  description = "Minimum number of nodes of k8s cluster"
  type        = number
  default     = 3
}

variable "max_size" {
  description = "Maximum number of nodes of k8s cluster"
  type        = number
  default     = 6
}

variable "desired_size" {
  description = "Desired number of nodes of k8s cluster"
  type        = number
  default     = 3
}

variable "disk_size" {
  description = "Disk size of nodes of k8s cluster"
  type        = number
  default     = 100
}

variable "ami_id" {
  description = "Node AMI Id"
  type        = string
  default     = null
}
variable "instance_types" {
  description = "Node instance types"
  type        = list(string)
  default     = ["m5.xlarge"]
}

variable "create_alb" {
  default     = false
  type        = bool
  description = "Variable to create the actual ALB"
}

variable "alb_certificate_arn" {
  default     = null
  type        = string
  description = "AWS Certificate arn"
}

variable "alb_internal" {
  default     = false
  type        = bool
  description = "If alb is internal"
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

variable "additional_admin_role_regex" {
  default     = [".*_k8s_runner_instance_role", ".*_platform_runner_role"]
  type        = set(string)
  description = "Additional regex of aws roles to be used to for cluster access"
}
