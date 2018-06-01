output "s3_bucket" {
  value = "${aws_s3_bucket.b.bucket}"
}

output "s3_bucket_website" {
  value = "${aws_s3_bucket.b.website_endpoint}"
}

output "s3_bucket_arn" {
  value = "${aws_s3_bucket.b.arn}"
}
