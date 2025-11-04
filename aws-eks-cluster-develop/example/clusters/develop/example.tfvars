cluster_name          = "example-eks"
cluster_version       = "1.30"
public_subnets        = ["subnet-06a130a87de4c40f4", "subnet-003561d13b94a2bbf", "subnet-08c7cf7a5d77907e4"]
control_plane_subnets = ["subnet-0cb521300db1f9f6e", "subnet-0a6b9ca193c44e823", "subnet-080dc7d9f3d3b9f57"]
node_group_subnets    = ["subnet-0cb521300db1f9f6e", "subnet-0a6b9ca193c44e823", "subnet-080dc7d9f3d3b9f57"]
credentials           = [
  { name : "artifactory_username", path : "/artifactory/ci_username", provider = "ssm" },
  { name : "artifactory_password", path : "/artifactory/ci_token", provider = "ssm" },
  { name : "splunk_token", path : "/fluentd/splunk/hec_token", provider = "ssm" },
  { name : "datadog_app_key", path : "/datadog/agent/appKey", provider = "ssm" },
  { name : "datadog_api_key", path : "/datadog/agent/apiKey", provider = "ssm" },
  { name : "contrast_api_key", path : "/specflow/contrast/apiKey", provider = "ssm" },
  { name : "contrast_service_key", path : "/specflow/contrast/serviceKey", provider = "ssm" },
  { name : "contrast_username", path : "/specflow/contrast/username", provider = "ssm" },
]

additional_admin_role_regex=["example-runner-develop-gitlab_k8s_runner_role","example-runner-develop-gitlab_platform_runner_role"]
