# Terraform bootstrap variables
variable "tfstate_bucket" {
  description = "Name of the S3 bucket used for Terraform state storage"
}

variable "data_bucket" {
  description = "Name of S3 bucket to use for data"
}

variable "tf_lock_dynamo_table" {
  description = "Name of DynamoDB table used for Terraform locking"
}

variable "event_dynamo_table" {
  description = "Name of DynamoDB table used for Terraform locking"
}

variable "athena_results_bucket" { }