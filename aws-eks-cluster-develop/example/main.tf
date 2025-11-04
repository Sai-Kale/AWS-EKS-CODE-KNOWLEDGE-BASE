module "eks-cluster" {
  source                      = "gitlab.spectrumflow.net/charter/aws-eks-cluster/aws"
  version                     = "2.0.0"
  cluster_name                = var.cluster_name
  cluster_version             = var.cluster_version
  public_subnets              = var.public_subnets
  control_plane_subnets       = var.control_plane_subnets
  node_group_subnets          = var.node_group_subnets
  credentials                 = var.credentials
  ami_id                      = var.ami_id
  min_size                    = var.min_size
  max_size                    = var.max_size
  desired_size                = var.desired_size
  disk_size                   = var.disk_size
  instance_types              = var.instance_types
  additional_admin_role_regex = var.additional_admin_role_regex
  create_alb                  = var.create_alb
  enable_istio                = true
  enable_nginx                = false
  enable_contrast_agent       = true
  falcon_cid                  = var.falcon_cid
  falcon_client               = var.falcon_client
  falcon_secret               = var.falcon_secret
  enable_metacontroller       = true
  alb_certificate_arn         = var.alb_certificate_arn
  alb_internal                = var.alb_internal
  node_group_labels = {
    "data-plane" = "apps",
    "solution"   = "apps",
    "platform"   = "apps"
  }
}


provider "aws" {
  default_tags {
    tags = {
      app_id     = "test_app_id"
      cost_code  = "test_cost_code"
      app_ref_id = "test_app_ref_id"
    }
  }
}
