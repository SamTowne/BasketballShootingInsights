locals {
  lambda_common_libs_layer_path = "${path.module}/workspace/output"
  lambda_common_libs_layer_zip_name = "${path.module}/workspace/output/lambdalayer.zip"
}


# Build an S3 bucket to store TF state
resource "aws_s3_bucket" "state_bucket" {
  bucket = var.tfstate_bucket
}

resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.state_bucket.id

  rule {
    bucket_key_enabled = true

    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.state_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Build a DynamoDB Table to use for Terraform state locking
resource "aws_dynamodb_table" "tf_lock_state" {
  name = var.tf_lock_dynamo_table
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_s3_bucket" "s3_data_bucket" {
  bucket = var.data_bucket
  acl    = "private"
  policy = <<EOT
  {
    "Version": "2012-10-17",
    "Id": "SIDataBucketPolicy",
    "Statement": [
        {
            "Sid": "lambda",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::272773485930:role/collection_lambda_role"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::shooting-insights-data/*"
        }
    ]
}
EOT
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data" {
  bucket = aws_s3_bucket.s3_data_bucket.id

  rule {
    bucket_key_enabled = true

    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "data" {
  bucket = aws_s3_bucket.s3_data_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

data "archive_file" "lambda_common_libs_layer_package" {
  type = "zip"
  source_dir = local.lambda_common_libs_layer_path
  output_path = local.lambda_common_libs_layer_zip_name
}

resource "aws_lambda_layer_version" "lambda_layer" {
  filename   = local.lambda_common_libs_layer_zip_name
  layer_name = "basketball-drill-bot"
  source_code_hash = data.archive_file.lambda_common_libs_layer_package.output_base64sha256

  compatible_runtimes = ["python3.8"]
}

output "data_bucket" {
  value = aws_s3_bucket.s3_data_bucket.bucket
}
output "data_bucket_arn" {
  value = aws_s3_bucket.s3_data_bucket.arn
} 
