output "aws_iam_access_key" {
  value = "${aws_iam_access_key.access_key.id}"
}

output "aws_iam_access_secret" {
  value = "${aws_iam_access_key.access_key.secret}"
}
