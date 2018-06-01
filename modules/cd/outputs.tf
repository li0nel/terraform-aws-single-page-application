output "aws_codecommit_repository_url" {
  value = "${aws_codecommit_repository.repo.clone_url_http}"
}
