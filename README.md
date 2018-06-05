# Content Delivery Network setup for your Single Page Application

Terraform module which lets you continuously deploy your SPA on AWS CloudFront.

These types of resources are supported:

* [CloudFront Distribution](https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html)
* [S3 Bucket](https://www.terraform.io/docs/providers/aws/d/s3_bucket.html)
* [CodePipeline](https://www.terraform.io/docs/providers/aws/r/codepipeline.html)
* [CodeBuild](https://www.terraform.io/docs/providers/aws/r/codebuild_project.html)

Root module calls these modules which can also be used separately to create independent resources:

* [cdn](https://github.com/li0nel/terraform-aws-single-page-application/tree/master/modules/cdn) - creates a CF distribution
* [s3](https://github.com/li0nel/terraform-aws-single-page-application/tree/master/modules/s3) - creates a S3 bucket
* [cd](https://github.com/li0nel/terraform-aws-single-page-application/tree/master/modules/cd) - creates the CD pipeline

## Usage

Create a `main.tf` file containing the following:

```hcl
module "single-page-application" {
  source  = "li0nel/single-page-application/aws"
  version = "0.0.6"

  stack_name  = "${var.stack_name}"
  aws_profile = "${var.aws_profile}"
  aws_region  = "${var.aws_region}"
  domain_name = "${var.domain_name}"
}
```

Run `terraform apply` then:

```bash
git remote add codecommit $(terraform output aws_codecommit_repository_url)

git config --global credential.helper '!aws --profile YOUR_AWS_PROFILE codecommit credential-helper $@'
git config --global credential.UseHttpPath true

git push codecommit YOUR_BRANCH:master
```

If you get an Access Denied (403) error from the Git repository when pushing, it's probably because OSX cached your temporary credentials.
You would need to find CodeCommit entries in KeyChain and delete them.

## Examples

* [Complete example](https://github.com/li0nel/terraform-aws-single-page-application/tree/master/examples)

## Authors

Module managed by [Lionel Martin](https://getlionel.com)

## License

Apache 2 Licensed. See LICENSE for full details
