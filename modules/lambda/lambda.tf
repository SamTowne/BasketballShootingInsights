resource "aws_iam_role" "lambda_role" {
  name = var.role

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
  name = "${var.function_name}_policy"
  description = "iam policy for ${var.function_name}"
  policy = var.lambda_policy_json
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_lambda_function" "lambda" {
  filename         = "collection.py"
  function_name    = var.function_name
  role             = aws_iam_role.lambda_role.arn
  handler          = var.handler
  runtime          = var.runtime
  source_code_hash = var.source_code_hash
}

data "archive_file" "lambda" {
  type = "zip"
  source_file = "./modules/lambda/${var.function_name}/${var.function_name}.py"
  output_path = "./modules/lambda/${var.function_name}/${var.function_name}_payload.zip"
}

output "source_file" {
  value = data.archive_file.lambda.source_file
}

output "output_path" {
  value = data.archive_file.lambda.output_path
}

output "output_arn" {
  value = aws_lambda_function.lambda.arn
}

output "output_invoke_arn" {
  value = aws_lambda_function.lambda.invoke_arn
}