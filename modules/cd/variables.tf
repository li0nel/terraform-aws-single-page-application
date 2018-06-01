variable "stack_name" {
  type = "string"
}

variable "bucket_name" {
  type = "string"
}

variable "bucket_arn" {
  type = "string"
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = "map"
  default     = {}
}
