data "aws_s3_bucket" "b" {
  bucket = "${var.s3_bucket}"
}

resource "aws_s3_bucket" "logs_bucket" {
  bucket_prefix = "cf-logs-${var.stack_name}-"
  acl           = "private"

  tags = "${merge(var.tags, map("Name", format("%s", var.stack_name)))}"
}

data "aws_acm_certificate" "certificate" {
  domain      = "*.cdn.${var.domain_name}"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
  provider    = "aws.us-east-1"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = "${data.aws_s3_bucket.b.website_endpoint}"
    origin_id   = "s3_origin"

    custom_origin_config {
      origin_protocol_policy = "http-only"
      http_port              = 80
      https_port             = 443
      origin_ssl_protocols   = ["TLSv1", "SSLv3"]
    }
  }

  tags = "${merge(var.tags, map("Name", format("%s", var.stack_name)))}"

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  logging_config {
    include_cookies = true
    bucket          = "${aws_s3_bucket.logs_bucket.bucket_domain_name}"
    prefix          = "cloudfront_logs"
  }

  aliases = ["${var.stack_name}.cdn.${var.domain_name}"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3_origin"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    lambda_function_association {
      event_type = "origin-request"
      lambda_arn = "${aws_lambda_function.lambda_at_edge.arn}:${aws_lambda_function.lambda_at_edge.version}"
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 900
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = "${data.aws_acm_certificate.certificate.arn}"
    ssl_support_method  = "sni-only"
  }
}

data "aws_route53_zone" "cdn" {
  name = "${var.domain_name}."
}

resource "aws_route53_record" "cdn_alias" {
  zone_id = "${data.aws_route53_zone.cdn.zone_id}"
  name    = "${var.stack_name}.cdn.${var.domain_name}"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.s3_distribution.domain_name}"
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = true
  }
}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_at_edge"
  output_path = "${path.module}/lambda_at_edge.zip"
}

resource "aws_iam_role" "iam_role" {
  name = "iam_role_${var.stack_name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com",
          "edgelambda.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "lambda_role_policy" {
  name = "lambda-policy-${var.stack_name}"
  role = "${aws_iam_role.iam_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
         "Effect": "Allow",
         "Action": [
            "logs:*"
         ],
         "Resource": [
            "*"
         ]
      }
  ]
}
EOF
}

resource "aws_lambda_function" "lambda_at_edge" {
  filename         = "${data.archive_file.lambda.output_path}"
  function_name    = "${var.stack_name}-lambda-at-edge"
  role             = "${aws_iam_role.iam_role.arn}"
  handler          = "index.handler"
  runtime          = "nodejs6.10"
  source_code_hash = "${base64sha256(file("${data.archive_file.lambda.output_path}"))}"
  publish          = "true"
  provider         = "aws.us-east-1"
}
