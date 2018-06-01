variable "stack_name" {
  type = "string"
}

variable "s3_bucket" {
  type = "string"
}

variable "domain_name" {
  type = "string"
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = "map"
  default     = {}
}
