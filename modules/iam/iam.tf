resource "aws_iam_user" "ci_user" {
  name = "${var.stack_name}-ci-user"
}

resource "aws_iam_access_key" "access_key" {
  user = "${aws_iam_user.ci_user.name}"
}

resource "aws_iam_user_policy" "policy" {
  name = "${var.stack_name}_iam_ci_user_policy"
  user = "${aws_iam_user.ci_user.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject",
        "s3:PutObjectAcl"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.s3_bucket}/*"
    },
    {
      "Action": [
        "cloudfront:CreateInvalidation"
      ],
      "Effect": "Allow",
      "Resource": "${var.cf_distribution_arn}"
    }
  ]
}
EOF
}
