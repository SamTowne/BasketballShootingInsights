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
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::shooting-insights-athena-results/*"
      ],
      "Principal": {
        "AWS": [
          "arn:aws:iam::272773485930:role/collection_lambda_role",
          "arn:aws:iam::272773485930:role/processing_lambda_role"
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

# Allow S3 Trigger of the Response Lambda

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "arn:aws:lambda:us-east-1:272773485930:function:response"
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.athena_results_bucket.arn
}

# Trigger for response to be ignited once all processing is complete
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

resource "aws_athena_named_query" "athena_query" {
  name      = "shooting_insights_table"
  database  = aws_athena_database.athena_db.name
  workgroup = aws_athena_workgroup.athena_workgroup.name
  query     = <<EOT
  CREATE EXTERNAL TABLE IF NOT EXISTS ${aws_athena_database.athena_db.name}.shooting_insights (
         `spot_1` int,
         `spot_2` int,
         `spot_3` int,
         `spot_4` int,
         `spot_5` int,
         `spot_6` int,
         `spot_7` int,
         `spot_8` int,
         `spot_9` int,
         `spot_10` int,
         `spot_11` int,
         `temp` int,
         `date` date,
         `time` string 
) 
ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'
WITH SERDEPROPERTIES (
         'serialization.format' = '1' ) LOCATION 's3://shooting-insights-data/collection/3point/' TBLPROPERTIES ('has_encrypted_data'='false');

  EOT
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
              "ses:SendEmail",
              "ses:SendRawEmail",
              "athena:StartQueryExecution",
              "glue:GetTable",
              "glue:GetDatabase"
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
              "${aws_s3_bucket.athena_results_bucket.arn}/*"
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

data "archive_file" "lambda" {
  type = "zip"
  source_file = "./modules/processing/processing.py"
  output_path = "./modules/processing/processing_payload.zip"
}

output "output_arn" {
  value = aws_lambda_function.lambda.arn
}

output "output_invoke_arn" {
  value = aws_lambda_function.lambda.invoke_arn
}

output "athena_results_bucket_arn" {
  value = aws_s3_bucket.athena_results_bucket.arn
}