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

module "single-page-application" {
  source  = "li0nel/single-page-application/aws"
  version = "0.0.6"

  stack_name  = "${var.stack_name}"
  aws_profile = "${var.aws_profile}"
  aws_region  = "${var.aws_region}"
  domain_name = "${var.domain_name}"
}
