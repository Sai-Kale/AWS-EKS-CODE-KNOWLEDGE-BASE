module "aws-tags" {
  version = "1.0.0"
  source  = "gitlab.spectrumflow.net/charter/aws-tags/aws"
}
module "eks" {
  source  = "gitlab.spectrumflow.net/charter/tf-mirror-terraform-aws-eks/aws"
  version = "20.37.1"

  cluster_name                             = var.cluster_name
  cluster_version                          = var.cluster_version
  cluster_endpoint_public_access           = var.cluster_endpoint_public_access
  cluster_endpoint_private_access          = var.cluster_endpoint_private_access
  cluster_endpoint_public_access_cidrs     = var.cluster_endpoint_public_access_cidrs
  create_cluster_security_group            = var.create_cluster_security_group
  cluster_security_group_id                = var.cluster_security_group_id
  cluster_additional_security_group_ids    = var.cluster_additional_security_group_ids
  create_node_security_group               = var.create_node_security_group
  node_security_group_additional_rules     = local.nodegroup_security_group_all_additional_rules
  cluster_security_group_additional_rules  = merge(var.cluster_security_group_additional_rules, local.subnet_cluster_security_group_additional_rules, local.pod_subnet_cluster_security_group_additional_rules, local.cluster_egress_security_group_additional_rules, local.public_access_security_group_additional_rules)
  create_iam_role                          = var.create_iam_role
  iam_role_arn                             = var.iam_role_arn
  iam_role_name                            = coalesce(var.iam_role_name, "${var.cluster_name}-cluster-role")
  iam_role_path                            = var.iam_role_path
  iam_role_description                     = "EKS Managed Cluster IAM Role for ${var.cluster_name}"
  enable_irsa                              = var.enable_irsa
  iam_role_use_name_prefix                 = false
  enable_cluster_creator_admin_permissions = var.enable_cluster_creator_admin_permissions
  cluster_ip_family                        = var.cluster_ip_family
  create_cni_ipv6_iam_policy               = var.create_cni_ipv6_iam_policy
  access_entries                           = merge(local.admin_access_entries, var.access_entries)

  cluster_addons = {
    coredns = {
      addon_version        = try(var.cluster_addons.coredns.version, null)
      configuration_values = try(jsonencode(var.cluster_addons.coredns.values), null)
    }
    kube-proxy = {
      addon_version        = try(var.cluster_addons.kube-proxy.version, null)
      configuration_values = try(jsonencode(var.cluster_addons.kube-proxy.values), null)
    }
    vpc-cni = {
      before_compute       = try(var.cluster_addons.before_compute, true)
      addon_version        = try(var.cluster_addons.vpc-cni.version, null)
      most_recent          = try(var.cluster_addons.vpc-cni.most_recent, null)
      configuration_values = try(jsonencode(var.cluster_addons.vpc-cni.values), null)
      timeouts = {
        create = try(var.cluster_addons.vpc-cni.timeouts.create, "30m")
        update = try(var.cluster_addons.vpc-cni.timeouts.update, "30m")
        delete = try(var.cluster_addons.vpc-cni.timeouts.delete, "30m")
      }
    }
  }
  vpc_id                   = var.vpc_id != "" ? var.vpc_id : data.aws_vpc.vpc.id
  subnet_ids               = var.node_group_subnets
  control_plane_subnet_ids = var.control_plane_subnets
  eks_managed_node_groups = {
    primary_ng = {
      name                     = "${var.cluster_name}-ng"
      iam_role_name            = "${var.cluster_name}-ng"
      iam_role_use_name_prefix = false
      iam_role_description     = "EKS managed node group for ${var.cluster_name}"
      ami_type                 = var.ami_type
      instance_types           = var.instance_types
      min_size                 = var.min_size
      max_size                 = var.max_size
      # This value is ignored after the initial creation
      # https://github.com/bryantbiggs/eks-desired-size-hack
      desired_size                    = var.desired_size
      metadata_options                = var.node_group_metadata_options
      capacity_type                   = var.capacity_type
      create_launch_template          = var.create_launch_template
      force_update_version            = var.force_update_version
      launch_template_name            = "${var.cluster_name}-lt"
      launch_template_use_name_prefix = true
      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = var.disk_size
            volume_type           = "gp3"
            iops                  = var.volume_iops
            throughput            = var.volume_throughput
            encrypted             = true
            delete_on_termination = true
          }
        }
      }
      update_config = {
        max_unavailable_percentage = 33
      }
      subnet_ids                   = var.node_group_subnets
      enable_bootstrap_user_data   = var.enable_bootstrap_user_data
      ami_id                       = var.automatic_ami_update_enabled ? coalesce(var.ami_id, data.aws_ami.eks_default_ami[0].image_id) : var.ami_id
      iam_role_additional_policies = local.worker_iam_role_additional_policies
      bootstrap_extra_args         = var.bootstrap_extra_args
      post_bootstrap_user_data     = var.post_bootstrap_user_data
      labels                       = var.node_group_labels
      tags                         = merge(data.aws_default_tags.provider.tags, var.tags)
    }
  }

  #-------------------------------
  # Cloudwatch Log Group (Optional):
  #-------------------------------
  create_cloudwatch_log_group            = var.create_cloudwatch_log_group
  cloudwatch_log_group_retention_in_days = var.cloudwatch_log_group_retention_in_days
  # A list of the desired control plane logging to enable
  cluster_enabled_log_types = var.cluster_enabled_log_types

  #-------------------------------
  # Cluster KMS Key
  #-------------------------------
  # A list of additional IAM ARNs that should have  FULL access (kms:*) in the KMS key policy
  # To allow terraform execution from local
  kms_key_administrators = toset(var.kms_admin_roles)
  # Deletion Waiting window. After the waiting period ends, AWS KMS deletes the KMS key
  kms_key_deletion_window_in_days = var.cluster_kms_key_deletion_window_in_days

  tags                     = merge(data.aws_default_tags.provider.tags, var.tags)
  node_security_group_tags = var.node_security_group_tags
}
