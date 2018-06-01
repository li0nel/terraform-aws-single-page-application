output "aws_codecommit_repository_url" {
  value = "${module.spa_cdn.aws_codecommit_repository_url}"
}

output "s3_bucket_website" {
  value = "${module.spa_cdn.s3_bucket_website}"
}

output "cloudfront_domain_name" {
  value = "${module.spa_cdn.cloudfront_domain_name}"
}

output "cloudfront_alias_domain_name" {
  value = "${module.spa_cdn.cloudfront_alias_domain_name}"
}
