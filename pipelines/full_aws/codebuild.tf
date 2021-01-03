resource "aws_iam_role" "code_build_role" {
  name = "${local.tag}-code-build-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "build-reqs" {
  role = aws_iam_role.code_build_role.name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [ "s3:GetObject", "s3:PutObject"],
      "Resource": ["${aws_s3_bucket.codepipeline_bucket.arn}/*"]
    }
  ]
}
POLICY
}

data "aws_caller_identity" "current" {}

data aws_s3_bucket f {
  bucket = "infrastructure-state-${data.aws_caller_identity.current.account_id}"
}

resource "aws_iam_role_policy" "terraform-updates" {
  role = aws_iam_role.code_build_role.name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "codepipeline:*",
        "codebuild:*",
        "iam:*",
        "s3:*",
        "codecommit:*",
        "states:*",
        "lambda:*",
        "dynamodb:*",
        "events:*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [ "s3:GetObject", "s3:PutObject"],
      "Resource": ["${data.aws_s3_bucket.f.arn}/*"]
    }
  ]
}
POLICY
}


resource "aws_codebuild_project" "codebuild-infra" {
  name          = "${local.tag}-build-infra"
  description   = "test_codebuild_project"
  build_timeout = "5"
  service_role  = aws_iam_role.code_build_role.arn
  source {
    type      = "CODEPIPELINE"
    buildspec = "configuration/terraform/stack/buildspec.yml"
  }
  artifacts {
    type      = "CODEPIPELINE"
    packaging = "ZIP"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/amazonlinux2-x86_64-standard:1.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "Environment"
      value = local.tag
    }
  }

  tags = {
    Environment = local.tag
  }
}
