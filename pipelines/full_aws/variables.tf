variable "region" {
  type    = string
  default = "us-west-2"
}

variable "tag" {
  type    = string
  default = "example"
}

// Base image for codebuild to run on. I'm personally a fan of no-frills AL2, so that's the default.
variable "base_image" {
  type    = string
  default = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
}

// You ecr image to build
variable "image" {
  type = string  
}

provider "aws" {
  region = var.region
}

terraform {
    backend "s3" {
        region = "us-west-2"
    }
}