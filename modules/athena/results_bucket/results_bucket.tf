# Build an AWS S3 bucket for Athena results
resource "aws_s3_bucket" "athena_results_bucket" {
  bucket = var.athena_results_bucket
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
        "arn:aws:s3:::shooting-insights-athena-results/*"
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
}

output "output_athena_results_bucket_name" {
  value = aws_s3_bucket.athena_results_bucket.bucket
}