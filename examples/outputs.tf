output "aws_codecommit_repository_url" {
  value = "${module.single-page-application.aws_codecommit_repository_url}"
}

output "s3_bucket_website" {
  value = "${module.single-page-application.s3_bucket_website}"
}

output "cloudfront_domain_name" {
  value = "${module.single-page-application.cloudfront_domain_name}"
}

output "cloudfront_alias_domain_name" {
  value = "${module.single-page-application.cloudfront_alias_domain_name}"
}
