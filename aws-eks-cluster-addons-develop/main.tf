terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "< 3.0.0"
    }

    kubectl = {
      source = "gavinbunney/kubectl"
    }
  }
}

