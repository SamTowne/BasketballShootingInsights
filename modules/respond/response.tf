resource "aws_iam_role" "lambda_role" {
  name = "response_lambda_role"

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
              "lambda:InvokeFunction",
              "athena:GetQueryResults"
          ],
          "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "lambda:InvokeFunction"
        ],
        "Resource": "${var.athena_bucket_arn}"
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
              "${var.athena_bucket_arn}",
              "${var.athena_bucket_arn}/*",
              "${var.temp_bucket_arn}",
              "${var.temp_bucket_arn}/*"
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
  filename         = "./modules/respond/response_payload.zip"
  function_name    = "response"
  role             = aws_iam_role.lambda_role.arn
  handler          = "response.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = filebase64sha256("./modules/respond/response_payload.zip")
}

data "archive_file" "lambda" {
  type = "zip"
  source_file = "./modules/respond/response.py"
  output_path = "./modules/respond/response_payload.zip"
}

output "output_arn" {
  value = aws_lambda_function.lambda.arn
}

output "output_invoke_arn" {
  value = aws_lambda_function.lambda.invoke_arn
}
