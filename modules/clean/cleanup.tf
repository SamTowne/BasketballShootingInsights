resource "aws_iam_role" "lambda_role" {
  name = "cleanup_lambda_role"

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
              "logs:PutLogEvents"
          ],
          "Resource": "*"
      },
      {
          "Effect": "Allow",
          "Action": [
              "s3:ListBucket",
              "s3:DeleteObject"
          ],
          "Resource": [
              "${var.temp_bucket_arn}",
              "${var.temp_bucket_arn}/*",
              "${var.athena_bucket_arn}",
              "${var.athena_bucket_arn}/*",
              "${var.processing_bucket_arn}",
              "${var.processing_bucket_arn}/*"
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
  filename         = "${path.module}/cleanup_payload.zip"
  function_name    = "cleanup"
  role             = aws_iam_role.lambda_role.arn
  handler          = "cleanup.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = filebase64sha256("${path.module}/cleanup_payload.zip")
}

data "archive_file" "lambda" {
  type = "zip"
  source_file = "${path.module}/cleanup.py"
  output_path = "${path.module}/cleanup_payload.zip"
}

output "output_arn" {
  value = aws_lambda_function.lambda.arn
}

output "output_invoke_arn" {
  value = aws_lambda_function.lambda.invoke_arn
}
