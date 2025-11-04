# provider "helm" {
#   kubernetes {
#     host                   = data.aws_eks_cluster.eks.endpoint
#     cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority.0.data)
#     exec {
#       api_version = "client.authentication.k8s.io/v1beta1"
#       args        = concat(["eks", "get-token", "--cluster-name", var.cluster_name])
#       command     = "aws"
#       env         = {
#         AWS_REGION = data.aws_region.current.name
#       }
#     }
#   }
# }

# provider "kubernetes" {
#   host                   = data.aws_eks_cluster.eks.endpoint
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority.0.data)
#   exec {
#     api_version = "client.authentication.k8s.io/v1beta1"
#     args        = concat(["eks", "get-token", "--cluster-name", var.cluster_name])
#     command     = "aws"
#     env         = {
#       AWS_REGION = data.aws_region.current.name
#     }
#   }
# }

