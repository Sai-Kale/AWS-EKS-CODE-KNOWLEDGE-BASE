data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
#Tags for the provider cant be passed to the ASG module, so we use this data source to get the tags.
data "aws_default_tags" "provider" {} 
data "aws_vpc" "vpc" {
  id = one(toset([for s in data.aws_subnet.eks_subnets : s.vpc_id]))
}

data "aws_subnet" "eks_subnets" {
  for_each = var.control_plane_subnets
  id       = each.value
}

data "aws_subnet" "node_subnets" {
  for_each = var.node_group_subnets
  id       = each.value
}

data "aws_iam_roles" "sub_admin_roles" {
  name_regex  = var.sub_admin_role_regex
  path_prefix = "/aws-reserved/sso.amazonaws.com/"
}

data "aws_iam_roles" "admin_roles" {
  name_regex  = var.admin_role_regex
  path_prefix = "/aws-reserved/sso.amazonaws.com/"
}

data "aws_iam_roles" "additional_roles" {
  for_each   = var.additional_admin_role_regex
  name_regex = each.value
}

data "aws_ami" "eks_default_ami" {
  count       = var.automatic_ami_update_enabled ? 1 : 0
  most_recent = true
  owners      = ["786534693165"]
  filter {
    name   = "name"
    values = ["charter_eks_${var.cluster_version}_al2023_x86_64_ami_*"]
  }
}

data "aws_ssm_parameter" "ssm_keys" {
  for_each = local.ssm_keys
  name     = each.key
}

data "aws_secretsmanager_secret" "bootstrap_secret" {
  for_each = local.asm_keys
  name     = each.value
}

data "aws_secretsmanager_secret_version" "secret_version" {
  for_each  = data.aws_secretsmanager_secret.bootstrap_secret
  secret_id = each.value.id
}
