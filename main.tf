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

module "cdn" {
  source      = "./modules/cdn"
  stack_name  = "${var.stack_name}"
  s3_bucket   = "${module.s3.s3_bucket}"
  domain_name = "${var.domain_name}"
}

module "s3" {
  source     = "./modules/s3"
  stack_name = "${var.stack_name}"
}

module "cd" {
  source      = "./modules/cd"
  stack_name  = "${var.stack_name}"
  bucket_name = "${module.s3.s3_bucket}"
  bucket_arn  = "${module.s3.s3_bucket_arn}"
}

//module "clickstream" {
//  source    = "./modules/clickstream"
//  stack_name = "${var.stack_name}"
//}


//module "app" {
//  source      = "./modules/app"
//  stack_name  = "${var.stack_name}"
//}

