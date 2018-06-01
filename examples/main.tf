terraform {
  backend "s3" {
    bucket               = "spa-myapp-tf"
    key                  = "main.tfstate"
    region               = "eu-west-1"
    profile              = "default"
    workspace_key_prefix = "workspaces"
  }
}

provider "aws" {
  region  = "${var.aws_region}"
  profile = "${var.aws_profile}"
  version = "~> 1.9"
}

provider "aws" {
  region  = "us-east-1"
  profile = "${var.aws_profile}"
  alias   = "us-east-1"
  version = "~> 1.9"
}

module "spa_cdn" {
  source = "https://github.com/li0nel/terraform-aws-single-page-application"

  stack_name = "${var.stack_name}"

  aws_profile = "${var.aws_profile}"

  aws_region = "${var.aws_region}"

  domain_name = "${var.domain_name}"
}