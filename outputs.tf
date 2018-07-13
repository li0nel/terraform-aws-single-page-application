output "s3_bucket_website" {
  value = "${module.s3.s3_bucket_website}"
}

output "s3_bucket" {
  value = "${module.s3.s3_bucket}"
}

output "cloudfront_domain_name" {
  value = "${module.cdn.cloudfront_domain_name}"
}

output "cloudfront_alias_domain_name" {
  value = "${module.cdn.cloudfront_alias_domain_name}"
}

output "cloudfront_distribution_arn" {
  value = "${module.cdn.cloudfront_distribution_arn}"
}
