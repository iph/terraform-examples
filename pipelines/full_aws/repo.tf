resource "aws_codecommit_repository" "core" {
  repository_name = "${var.tag}-project"
  description     = "Core base to commit to"

  tags = {
    stack = var.tag
  }
}

resource "aws_ecr_repository" "images" {
  name = "${var.tag}-images"
  image_tag_mutability = "MUTABLE"

  tags = {
    stack = var.tag
  }
}