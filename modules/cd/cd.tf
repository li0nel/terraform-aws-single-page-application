resource "aws_codecommit_repository" "repo" {
  repository_name = "${var.stack_name}-repository"
}

resource "aws_s3_bucket" "artifact" {
  bucket_prefix = "${var.stack_name}-artifact-"
  acl           = "private"

  tags {
    "app_name" = "${var.stack_name}"
  }
}

//resource "aws_s3_bucket" "codebuild_cache" {
//  bucket_prefix = "${var.stack_name}-cache-"
//  acl           = "private"
//
//  tags {
//    "app_name" = "${var.stack_name}"
//  }
//}

resource "aws_iam_role" "iam_role" {
  name = "${var.stack_name}-codepipeline-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "codepipeline_policy"
  role = "${aws_iam_role.iam_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObject"
      ],
      "Resource": [
        "${aws_s3_bucket.artifact.arn}",
        "${aws_s3_bucket.artifact.arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::codepipeline*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "codecommit:GetBranch",
        "codecommit:GetCommit",
        "codecommit:UploadArchive",
        "codecommit:GetUploadArchiveStatus",
        "codecommit:CancelUploadArchive"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

//resource "aws_kms_key" "s3kmskey" {}

resource "aws_codepipeline" "pipeline" {
  name     = "${var.stack_name}"
  role_arn = "${aws_iam_role.iam_role.arn}"

  artifact_store {
    location = "${aws_s3_bucket.artifact.bucket}"
    type     = "S3"

    //    encryption_key {
    //      id   = "${aws_kms_key.s3kmskey.arn}"
    //      type = "KMS"
    //    }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["artifact"]

      configuration {
        RepositoryName = "${aws_codecommit_repository.repo.repository_name}"
        BranchName     = "master"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["artifact"]
      version         = "1"

      configuration {
        ProjectName = "${aws_codebuild_project.codebuild.name}"
      }
    }
  }
}

resource "aws_iam_role" "codebuild_role" {
  name = "codebuild-role-${var.stack_name}"

  force_detach_policies = true

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

resource "aws_iam_policy" "codebuild_policy" {
  name        = "codebuild-policy-${var.stack_name}"
  path        = "/service-role/"
  description = "Policy used in trust relationship with CodeBuild"

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
      "Effect":"Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:ListBucket",
        "s3:GetBucketPolicy"
      ],
      "Resource": [
        "${aws_s3_bucket.artifact.arn}/*",
        "${aws_s3_bucket.artifact.arn}",
        "${var.bucket_arn}/*"
      ]
    }
  ]
}
POLICY
}

resource "aws_iam_policy_attachment" "codebuild_policy_attachment" {
  name       = "codebuild-policy-attachment-${var.stack_name}"
  policy_arn = "${aws_iam_policy.codebuild_policy.arn}"
  roles      = ["${aws_iam_role.codebuild_role.id}"]
}

resource "aws_codebuild_project" "codebuild" {
  name = "${var.stack_name}"

  build_timeout = "5"
  service_role  = "${aws_iam_role.codebuild_role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

//  cache {
//    type     = "S3"
//    location = "${aws_s3_bucket.codebuild_cache.id}"
//  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/nodejs:6.3.1"
    type         = "LINUX_CONTAINER"

    environment_variable {
      "name"  = "BUCKET_NAME"
      "value" = "${var.bucket_name}"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "terraform/modules/cd/buildspec.yaml"
  }
}
