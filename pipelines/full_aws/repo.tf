provider "aws" {
  region = var.region
}

locals {
  tag = var.tag
}

variable "region" {
  type = "string"
  default = "us-west-2"
}

variable "tag" {
  type = "string"
}

terraform {
  backend "s3" {
    region = "us-west-2"
  }
}

resource "aws_codecommit_repository" "core" {
  repository_name = "${local.tag}-repo"
  description     = "Core code base"

  tags = {
    stack = local.tag
  }
}
