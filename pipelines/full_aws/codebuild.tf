resource "aws_iam_role" "code_build_role" {
  name = "${var.tag}-code-build-role"

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

// Policy for fiddling with this terraform infrastructure, so need all the things that will be directly edited
// by terraform. To make it easier, I went with the services in use, which some people may not like. Edit at will.
resource "aws_iam_role_policy" "terraform-infra-updates" {
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
        "events:*"
      ]
    }
  ]
}
POLICY
}

resource "aws_codebuild_project" "codebuild-infra" {
  name          = "${var.tag}-build-infra"
  description   = "test_codebuild_project"
  build_timeout = "5"
  service_role  = aws_iam_role.code_build_role.arn
  source {
    type      = "CODEPIPELINE"
    buildspec = "pipelines/full_aws/buildspec.yml"
  }
  artifacts {
    type      = "CODEPIPELINE"
    packaging = "ZIP"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = var.base_image
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "Environment"
      value = var.tag
    }
  }

  tags = {
    Environment = var.tag
  }
}
