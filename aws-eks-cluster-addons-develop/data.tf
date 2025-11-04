data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_ecrpublic_authorization_token" "ecr_token" {}

data "aws_eks_cluster" "eks" {
  name = var.cluster_name
}
