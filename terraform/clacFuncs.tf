
// Define the AWS provider
provider "aws" {
  region = "us-east-1"
}

//Zip the files
data "archive_file" "addition" {
  type        = "zip"
  source_dir  = "python"
  output_path = "python/addition.zip"
}

data "archive_file" "subtraction" {
  type        = "zip"
  source_dir  = "python"
  output_path = "python/subtraction.zip"
}

data "archive_file" "multiplication" {
  type        = "zip"
  source_dir  = "python"
  output_path = "python/multiplication.zip"
}

data "archive_file" "division" {
  type        = "zip"
  source_dir  = "python"
  output_path = "python/division.zip"
}


// AWS Lambda function for addition
resource "aws_lambda_function" "addition_function" {
  function_name = "calculator_addition"
  runtime       = "python3.12"
  handler       = "addition.handler"
  timeout       = 10
  memory_size   = 128
  role          = aws_iam_role.lambda_execution_role.arn

  // Function code
  filename = "python/addition.zip"
}

// AWS Lambda function for subtraction
resource "aws_lambda_function" "subtraction_function" {
  function_name = "calculator_subtraction"
  runtime       = "python3.12"
  handler       = "subtraction.handler"
  timeout       = 10
  memory_size   = 128
  role          = aws_iam_role.lambda_execution_role.arn

  // Function code
  filename = "python/subtraction.zip"
}

// AWS Lambda function for multiplication
resource "aws_lambda_function" "multiplication_function" {
  function_name = "calculator_multiplication"
  runtime       = "python3.12"
  handler       = "multiplication.handler"
  timeout       = 10
  memory_size   = 128
  role          = aws_iam_role.lambda_execution_role.arn

  // Function code
  filename = "python/multiplication.zip"
}

// AWS Lambda function for division
resource "aws_lambda_function" "division_function" {
  function_name = "calculator_division"
  runtime       = "python3.12"
  handler       = "division.handler"
  timeout       = 10
  memory_size   = 128
  role          = aws_iam_role.lambda_execution_role.arn

  // Function code
  filename = "python/division.zip"
}

// =API Gateway REST API
resource "aws_api_gateway_rest_api" "calculator_api" {
  name        = "calculator_api"
  description = "API Gateway for calculator functions"
}

// API Gateway resources for each Lambda function
resource "aws_api_gateway_resource" "addition_resource" {
  rest_api_id = aws_api_gateway_rest_api.calculator_api.id
  parent_id   = aws_api_gateway_rest_api.calculator_api.root_resource_id
  path_part   = "add"
}

resource "aws_api_gateway_resource" "subtraction_resource" {
  rest_api_id = aws_api_gateway_rest_api.calculator_api.id
  parent_id   = aws_api_gateway_rest_api.calculator_api.root_resource_id
  path_part   = "sub"
}

resource "aws_api_gateway_resource" "multiplication_resource" {
  rest_api_id = aws_api_gateway_rest_api.calculator_api.id
  parent_id   = aws_api_gateway_rest_api.calculator_api.root_resource_id
  path_part   = "mul"
}

resource "aws_api_gateway_resource" "division_resource" {
  rest_api_id = aws_api_gateway_rest_api.calculator_api.id
  parent_id   = aws_api_gateway_rest_api.calculator_api.root_resource_id
  path_part   = "div"
}

// API Gateway methods for each Lambda function
resource "aws_api_gateway_method" "addition_method" {
  rest_api_id   = aws_api_gateway_rest_api.calculator_api.id
  resource_id   = aws_api_gateway_resource.addition_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "subtraction_method" {
  rest_api_id   = aws_api_gateway_rest_api.calculator_api.id
  resource_id   = aws_api_gateway_resource.subtraction_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "multiplication_method" {
  rest_api_id   = aws_api_gateway_rest_api.calculator_api.id
  resource_id   = aws_api_gateway_resource.multiplication_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "division_method" {
  rest_api_id   = aws_api_gateway_rest_api.calculator_api.id
  resource_id   = aws_api_gateway_resource.division_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

// API Gateway integrations for each Lambda function
resource "aws_api_gateway_integration" "addition_integration" {
  rest_api_id             = aws_api_gateway_rest_api.calculator_api.id
  resource_id             = aws_api_gateway_resource.addition_resource.id
  http_method             = aws_api_gateway_method.addition_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.addition_function.invoke_arn
}

resource "aws_api_gateway_integration" "subtraction_integration" {
  rest_api_id             = aws_api_gateway_rest_api.calculator_api.id
  resource_id             = aws_api_gateway_resource.subtraction_resource.id
  http_method             = aws_api_gateway_method.subtraction_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.subtraction_function.invoke_arn
}

resource "aws_api_gateway_integration" "multiplication_integration" {
  rest_api_id             = aws_api_gateway_rest_api.calculator_api.id
  resource_id             = aws_api_gateway_resource.multiplication_resource.id
  http_method             = aws_api_gateway_method.multiplication_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.multiplication_function.invoke_arn
}

resource "aws_api_gateway_integration" "division_integration" {
  rest_api_id             = aws_api_gateway_rest_api.calculator_api.id
  resource_id             = aws_api_gateway_resource.division_resource.id
  http_method             = aws_api_gateway_method.division_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.division_function.invoke_arn
}

// APi gateway permissions for Lambda functions
resource "aws_lambda_permission" "addition_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.addition_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:us-east-1:904365110615:${aws_api_gateway_rest_api.calculator_api.id}/*/${aws_api_gateway_method.addition_method.http_method}${aws_api_gateway_resource.addition_resource.path}"
}

resource "aws_lambda_permission" "subtraction_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.subtraction_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.calculator_api.execution_arn}/*/*/*"
}

resource "aws_lambda_permission" "multiplication_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.multiplication_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.calculator_api.execution_arn}/*/*/*"
}

resource "aws_lambda_permission" "division_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.division_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.calculator_api.execution_arn}/*/*/*"
}

// Deploy the API Gateway
resource "aws_api_gateway_deployment" "calculator_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.calculator_api.id
  stage_name  = "dev"
  depends_on = [
    aws_api_gateway_method.addition_method,
    aws_api_gateway_method.subtraction_method,
    aws_api_gateway_method.multiplication_method,
    aws_api_gateway_method.division_method,
    aws_api_gateway_integration.addition_integration,
    aws_api_gateway_integration.subtraction_integration,
    aws_api_gateway_integration.multiplication_integration,
    aws_api_gateway_integration.division_integration,
    aws_lambda_permission.addition_permission,
    aws_lambda_permission.subtraction_permission,
    aws_lambda_permission.multiplication_permission,
    aws_lambda_permission.division_permission
  ]
}

// Roles and Plolicies for Lambda functions
resource "aws_iam_role" "lambda_execution_role" {
  name               = "lambda_execution_role"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_policy" "lambda_execution_policy" {
  name        = "lambda_execution_policy"
  description = "Policy for Lambda execution role"
  policy      = <<EOF
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
            "Resource": "arn:aws:logs:*:*:*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_execution_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_execution_policy.arn
}