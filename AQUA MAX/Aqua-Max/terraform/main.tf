terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.3.0"
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  description = "The AWS region to deploy to"
  type        = string
  default     = "us-east-1"
}

variable "env_variables" {
  description = "Lambda environment variables"
  type = map(string)
  default = {
    STAGE = "dev"
    DEBUG = "true"
  }
}

variable "subnet_ids" {
  type = list(string)
  default = ["subnet-xxxxxxxx", "subnet-yyyyyyyy"]
}

variable "security_group_ids" {
  type = list(string)
  default = ["sg-zzzzzzzz"]
}

variable "lambda_bucket_name" {
  description = "S3 bucket name for Lambda deployments"
  type        = string
  default     = "my-lambda-deployment-bucket"
}

variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "exampleLambda"
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = var.lambda_bucket_name
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "example_lambda" {
  function_name = var.lambda_function_name
  handler       = "exampleLambda.handler"
  runtime       = "nodejs18.x"
  role          = aws_iam_role.lambda_exec_role.arn
  filename      = "dist/lambdas/exampleLambda.js"
  source_code_hash = filebase64sha256("dist/lambdas/exampleLambda.js")

  environment {
    variables = var.env_variables
  }

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }
}

output "bucket_name" {
  value = aws_s3_bucket.lambda_bucket.bucket
}

output "lambda_function_name" {
  value = aws_lambda_function.example_lambda.function_name
}