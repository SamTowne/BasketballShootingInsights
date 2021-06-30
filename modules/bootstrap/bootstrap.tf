# Build an S3 bucket to store TF state
resource "aws_s3_bucket" "state_bucket" {
  bucket = var.tfstate_bucket

  # Tells AWS to encrypt the S3 bucket at rest by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  # Tells AWS to keep a version history of the state file
  versioning {
    enabled = true
  }

  lifecycle_rule {
    id = "state bucket lifecycle"
    enabled = true
    abort_incomplete_multipart_upload_days = 1
    noncurrent_version_transition {
      days = 1
      storage_class = "INTELLIGENT_TIERING"      
    }

    transition {
      storage_class = "INTELLIGENT_TIERING"
    }
  }  
}

# Build a DynamoDB to use for terraform state locking
resource "aws_dynamodb_table" "tf_lock_state" {
  name = var.tf_lock_dynamo_table

  # Pay per request is cheaper for low-i/o applications, like our TF lock state
  billing_mode = "PAY_PER_REQUEST"

  # Hash key is required, and must be an attribute
  hash_key = "LockID"

  # Attribute LockID is required for TF to use this table for lock state
  attribute {
    name = "LockID"
    type = "S"
  }
}

# Build an AWS S3 bucket for storing lambda data
resource "aws_s3_bucket" "s3_data_bucket" {
  bucket = var.data_bucket
  acl    = "private"
  policy = <<EOT
{
  "Id": "SIDataBucketPolicy",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "lambda",
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::shooting-insights-data/*"
      ],
      "Principal": {
        "AWS": [
          "arn:aws:iam::272773485930:role/collection_lambda_role"
        ]
      }
    }
  ]
}
  EOT

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule {
    id = "data bucket lifecycle"
    enabled = true
    abort_incomplete_multipart_upload_days = 1
    
    noncurrent_version_expiration {
      days = 1
    }

    transition {
      storage_class = "INTELLIGENT_TIERING"
    }
  }

}

# Output name of data bucket back to main.tf

output "data_bucket" {
  value = aws_s3_bucket.s3_data_bucket.bucket
}
output "data_bucket_arn" {
  value = aws_s3_bucket.s3_data_bucket.arn
}