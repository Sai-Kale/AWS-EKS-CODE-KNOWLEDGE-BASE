cluster_name          = "example2-eks"
cluster_version       = "1.30"
control_plane_subnets = ["subnet-0236f4f8ccd21504f", "subnet-0189bd0b3abd3eadd", "subnet-04105720dc0c74a54"]
node_group_subnets    = ["subnet-0d543bdd5cf40eb54", "subnet-0154c6f77a80cab3b", "subnet-09bddb3a48f3b1e6e"]
public_subnets        = ["subnet-05b8f0611c7dbc903", "subnet-08e668c36b48f6747", "subnet-025df13a09407f976"]
ami_id                = "ami-09a1fc552fd2c3cd8"
credentials           = [
  { name : "artifactory_username", path : "/artifactory/ci_username", provider = "ssm" }, #Required
  { name : "artifactory_password", path : "/artifactory/ci_token", provider = "ssm" }, #Required
  { name : "cluster_bootstrap", path : "/clusters/bootstrap", provider = "asm" } # Looks up secret instead of SSM
]
min_size        = 3
desired_size    = 3
max_size        = 6
disk_size       = 100
create_alb      = true
# Cert required when creating ALB
alb_certificate_arn = "arn:aws:acm:us-east-1:927524452786:certificate/dd3c2fc3-2b2f-428f-afc4-efcf9cf2c07d"
