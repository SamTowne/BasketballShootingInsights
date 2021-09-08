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
  }
}

output "data_bucket" {
  value = aws_s3_bucket.s3_data_bucket.bucket
}
output "data_bucket_arn" {
  value = aws_s3_bucket.s3_data_bucket.arn
} 
