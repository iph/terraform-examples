provider "aws" {
  region = var.region
}

resource "aws_codecommit_repository" "core" {
  repository_name = "${var.tag}-project"
  description     = "Core base to commit to"

  tags = {
    stack = var.tag
  }
}
