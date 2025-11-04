terraform {
  required_version = "~> 1.6"

  required_providers {
    tls = {
      source  = "hashicorp/tls"
      version = "4.1.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.13.1"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "2.3.7"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.4"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.100"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.19.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.37.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.0.2"
    }
  }
}
provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = concat(["eks", "get-token", "--cluster-name", module.eks.cluster_name])
      command     = "aws"
      env = {
        AWS_REGION = data.aws_region.current.name
      }
    }
  }
}
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = concat(["eks", "get-token", "--cluster-name", module.eks.cluster_name])
    command     = "aws"
    env = {
      AWS_REGION = data.aws_region.current.name
    }
  }
}

provider "kubectl" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = concat(["eks", "get-token", "--cluster-name", module.eks.cluster_name])
    command     = "aws"
    env = {
      AWS_REGION = data.aws_region.current.name
    }
  }
  load_config_file = false
}
