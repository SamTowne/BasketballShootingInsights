# Build an AWS S3 bucket for Athena results
resource "aws_s3_bucket" "athena_results_bucket" {
  bucket = "shooting-insights-athena-results"
  acl    = "private"
  policy = <<EOT
{
  "Id": "SIDataBucketPolicy",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "lambda",
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::shooting-insights-athena-results/*"
      ],
      "Principal": {
        "AWS": [
          "arn:aws:iam::272773485930:role/collection_lambda_role",
          "arn:aws:iam::272773485930:role/processing_lambda_role",
          "arn:aws:iam::272773485930:role/response_lambda_role",
          "arn:aws:iam::272773485930:role/cleanup_lambda_role"
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
    id = "athena bucket lifecycle"
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

# Build an AWS S3 bucket for setup processing results
resource "aws_s3_bucket" "setup_processing_results_bucket" {
  bucket = "shooting-insights-setup-processing-results"
  acl    = "private"
  policy = <<EOT
{
  "Id": "SIDataBucketPolicy",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "lambda",
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::shooting-insights-setup-processing-results/*"
      ],
      "Principal": {
        "AWS": [
          "arn:aws:iam::272773485930:role/collection_lambda_role",
          "arn:aws:iam::272773485930:role/cleanup_lambda_role"
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
    id = "athena bucket lifecycle"
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

# Processing Trigger 
resource "aws_lambda_permission" "processing_trigger_allow_bucket" {
  statement_id  = "ProcessingAllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "arn:aws:lambda:us-east-1:272773485930:function:processing"
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.setup_processing_results_bucket.arn
}

# Notification to invoke processing lambda function, to start once the Setup-Processing Athena Query Exection(s) are complete
resource "aws_s3_bucket_notification" "processing_trigger_bucket_notification" {
  bucket = aws_s3_bucket.setup_processing_results_bucket.id

  lambda_function {
    lambda_function_arn = "arn:aws:lambda:us-east-1:272773485930:function:processing"
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "create_table_query/"
    filter_suffix       = ".txt"
  }

  depends_on = [aws_lambda_permission.processing_trigger_allow_bucket]
}

# Response Trigger
resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "arn:aws:lambda:us-east-1:272773485930:function:response"
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.athena_results_bucket.arn
}

# Notification to invoke response lambda function, to start once the Processing Athena Query Execution(s) are complete
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.athena_results_bucket.id

  lambda_function {
    lambda_function_arn = "arn:aws:lambda:us-east-1:272773485930:function:response"
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "total_made_each_spot_query/"
    filter_suffix       = ".csv"
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}

resource "aws_athena_database" "athena_db" {
  name   = "shooting_insights"
  bucket = aws_s3_bucket.athena_results_bucket.bucket

  depends_on = [
    aws_s3_bucket.athena_results_bucket
  ]
}

resource "aws_athena_workgroup" "athena_workgroup" {
  name = "shooting_insights"
}

resource "aws_iam_role" "lambda_role" {
  name = "processing_lambda_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_policy" {
  name = "${aws_lambda_function.lambda.function_name}_policy"
  description = "iam policy for ${aws_lambda_function.lambda.function_name}"
  policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Effect": "Allow",
          "Action": [
              "logs:CreateLogGroup",
              "logs:CreateLogStream",
              "logs:PutLogEvents",
              "athena:*",
              "glue:*",
              "lambda:InvokeFunction"
          ],
          "Resource": "*"
      },
      {
          "Effect": "Allow",
          "Action": [
              "s3:GetBucketLocation",
              "s3:GetObject",
              "s3:ListBucket",
              "s3:ListBucketMultipartUploads",
              "s3:AbortMultipartUpload",
              "s3:PutObject",
              "s3:ListMultipartUploadParts"
          ],
          "Resource": [
              "${var.data_bucket_arn}",
              "${var.data_bucket_arn}/*",
              "${aws_s3_bucket.athena_results_bucket.arn}",
              "${aws_s3_bucket.athena_results_bucket.arn}/*",
              "arn:aws:s3:::shooting-insights-temp",
              "arn:aws:s3:::shooting-insights-temp/*"
          ]
      }
  ]
}
EOT
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_lambda_function" "lambda" {
  filename         = "./modules/processing/processing_payload.zip"
  function_name    = "processing"
  role             = aws_iam_role.lambda_role.arn
  handler          = "processing.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = filebase64sha256("./modules/processing/processing_payload.zip")
}

### Setup-Processing Lambda
resource "aws_iam_policy" "setup_processing_lambda_policy" {
  name = "${aws_lambda_function.setup_processing_lambda.function_name}_policy"
  description = "iam policy for ${aws_lambda_function.setup_processing_lambda.function_name}"
  policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Effect": "Allow",
          "Action": [
              "logs:CreateLogGroup",
              "logs:CreateLogStream",
              "logs:PutLogEvents",
              "athena:*",
              "glue:*",
              "lambda:InvokeFunction"
          ],
          "Resource": "*"
      },
      {
          "Effect": "Allow",
          "Action": [
              "s3:GetBucketLocation",
              "s3:GetObject",
              "s3:ListBucket",
              "s3:ListBucketMultipartUploads",
              "s3:AbortMultipartUpload",
              "s3:PutObject",
              "s3:ListMultipartUploadParts"
          ],
          "Resource": [
            "${var.data_bucket_arn}",
            "${var.data_bucket_arn}/*",
            "arn:aws:s3:::shooting-insights-temp",
            "arn:aws:s3:::shooting-insights-temp/*",
            "${aws_s3_bucket.setup_processing_results_bucket.arn}",
            "${aws_s3_bucket.setup_processing_results_bucket.arn}/*"
          ]
      }
  ]
}
EOT
}

resource "aws_iam_role_policy_attachment" "setup_processing_lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.setup_processing_lambda_policy.arn
}

resource "aws_lambda_function" "setup_processing_lambda" {
  filename         = "./modules/processing/setup_processing_payload.zip"
  function_name    = "setup_processing"
  role             = aws_iam_role.lambda_role.arn
  handler          = "setup_processing.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = filebase64sha256("./modules/processing/setup_processing_payload.zip")
}

data "archive_file" "lambda" {
  type = "zip"
  source_file = "./modules/processing/processing.py"
  output_path = "./modules/processing/processing_payload.zip"
}

data "archive_file" "setup_processing_lambda" {
  type = "zip"
  source_file = "./modules/processing/setup_processing.py"
  output_path = "./modules/processing/setup_processing_payload.zip"
}

output "output_arn" {
  value = aws_lambda_function.lambda.arn
}

output "output_invoke_arn" {
  value = aws_lambda_function.lambda.invoke_arn
}

output "athena_bucket_arn" {
  value = aws_s3_bucket.athena_results_bucket.arn
}

output "processing_bucket_arn" {
  value = aws_s3_bucket.setup_processing_results_bucket.arn
}