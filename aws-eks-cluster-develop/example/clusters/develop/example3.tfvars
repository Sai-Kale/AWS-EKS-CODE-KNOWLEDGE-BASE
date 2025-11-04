######## EKS #########

cluster_name          = "meta-controller"
cluster_version       = "1.30"
control_plane_subnets = ["subnet-0236f4f8ccd21504f", "subnet-0189bd0b3abd3eadd", "subnet-04105720dc0c74a54"]
node_group_subnets    = ["subnet-0d543bdd5cf40eb54", "subnet-0154c6f77a80cab3b", "subnet-09bddb3a48f3b1e6e"]
public_subnets        = ["subnet-05b8f0611c7dbc903", "subnet-08e668c36b48f6747", "subnet-025df13a09407f976"]
ami_id                = "ami-09a1fc552fd2c3cd8"
instance_types        = ["m5.large"]
credentials = [
  { name : "artifactory_username", path : "/artifactory/ci_username", provider = "ssm" },
  { name : "artifactory_password", path : "/artifactory/ci_token", provider = "ssm" },
  { name : "splunk_token", path : "/fluentd/splunk/hec_token", provider = "ssm" },
  { name : "datadog_app_key", path : "/datadog/agent/appKey", provider = "ssm" },
  { name : "datadog_api_key", path : "/datadog/agent/apiKey", provider = "ssm" },
  { name : "contrast_api_key", path : "/specflow/contrast/apiKey", provider = "ssm" },
  { name : "contrast_service_key", path : "/specflow/contrast/serviceKey", provider = "ssm" },
  { name : "contrast_username", path : "/specflow/contrast/username", provider = "ssm" },
]
min_size                    = 3
desired_size                = 3
max_size                    = 6
disk_size                   = 100
create_alb                  = true
alb_internal                = false
additional_admin_role_regex = ["specflow-qa-gitlab_platform_runner_role"]

cluster_addons = {
  vpc-cni = {
    version        = "v1.19.2-eksbuild.1"
    before_compute = true
    most_recent    = true
    values = {
      env = {
        AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG = "true"
        ENI_CONFIG_LABEL_DEF               = "topology.kubernetes.io/zone"
        ENABLE_PREFIX_DELEGATION           = "true"
        WARM_PREFIX_TARGET                 = "1"
      }
    }
    timeouts = {
      create = "30m"
    }
  }
  coredns = {
    version = "v1.11.4-eksbuild.2"
    values = {
      resources = {
        limits = {
          memory = "500Mi"
        }
      }
    }
  }
  kube-proxy = {
    version = "v1.31.3-eksbuild.2"
    values  = {} 
  }
}

###### Networking #####
vpc_id     = "vpc-06e7af1a7c27f3f1c"
aws_region = "us-east-1"
