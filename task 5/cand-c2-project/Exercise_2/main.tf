provider "aws" {
  access_key = ""
  secret_key = ""
  region     = var.aws_region
}

# Upload greet_lambda.py to S3
data "archive_file" "lambda_greet" {
  type = "zip"

  source_dir  = "${path.module}/greet"
  output_path = "${path.module}/greet.zip"
}

resource "aws_s3_bucket_object" "lambda_greet" {
  bucket = "terraform-totos"

  key    = "greet.zip"
  source = data.archive_file.lambda_greet.output_path

  etag = filemd5(data.archive_file.lambda_greet.output_path)
}

# Create lambda function
resource "aws_lambda_function" "greet_lambda" {
  function_name = "GreetLambda"

  s3_bucket = "terraform-totos"
  s3_key    = aws_s3_bucket_object.lambda_greet.key

  runtime = "python3.9"
  handler = "greet_lambda.lambda_handler"
  environment {
    variables = {
      greeting = "greeting"
    }
  }
  source_code_hash = data.archive_file.lambda_greet.output_base64sha256

  role = aws_iam_role.lambda_exec.arn

  vpc_config {
    subnet_ids         = ["subnet-b3e6cb92"]
    security_group_ids = ["sg-2055ce3e"]
  }
}

resource "aws_cloudwatch_log_group" "greet_lambda" {
  name = "/aws/lambda/${aws_lambda_function.greet_lambda.function_name}"

  retention_in_days = 30
}

resource "aws_iam_role" "lambda_exec" {
  name = "serverless_lambda"

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

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
