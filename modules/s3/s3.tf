resource "aws_s3_bucket" "b" {
  bucket_prefix = "spa-"
  acl           = "public-read"

  website {
    index_document = "index.html"
    error_document = "index.html"
  }

  tags = "${merge(var.tags, map("Name", format("%s", var.stack_name)))}"
}
