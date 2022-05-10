resource "aws_iam_role" "this" {
  name = "${var.function_name}-execution"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

resource "aws_iam_policy" "this" {
  name        = "${var.function_name}-execution"
  description = "${var.function_name} execution policy"

  policy = jsonencode({
    Statement = [{
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      Effect = "Allow"
      Resource = [
        "arn:aws:logs:*:${local.account_id}:log-group:/aws/lambda/${var.function_name}*:*"
      ]
      }, {
      Action = [
        "ec2:CreateNetworkInterface",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeNetworkInterfaces"
      ],
      Effect   = "Allow"
      Resource = ["*"]
      }, {
      Action = [
        "ssm:GetParameter*"
      ],
      Effect = "Allow"
      Resource = [
        "arn:aws:ssm:*:${local.account_id}:parameter/symops.com/${var.function_name}/*"
      ]
    }]
    Version = "2012-10-17"
  })

  tags = var.tags
}
