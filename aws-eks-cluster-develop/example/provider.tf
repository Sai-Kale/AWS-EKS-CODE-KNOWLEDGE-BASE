terraform {
  backend "http" {
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
