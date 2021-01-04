variable "region" {
  type    = string
  default = "us-west-2"
}

provider "aws" {
  region = var.region
}

// Make buckets unique on the account level for terraform
data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "terraform_state" {
    bucket = "terraform-infrastructure-state-${data.aws_caller_identity.current.account_id}"
    acl = "private"
}