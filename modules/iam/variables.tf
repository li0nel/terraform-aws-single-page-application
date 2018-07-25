variable "stack_name" {
  type = "string"
}

variable "s3_bucket" {
  type = "string"
}

variable "cf_distribution_arn" {
  type = "string"
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = "map"
  default     = {}
}
