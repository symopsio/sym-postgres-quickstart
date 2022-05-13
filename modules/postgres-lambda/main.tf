locals {
  pg_password_key = "/symops.com/${var.function_name}/PG_PASSWORD"

  security_group_ids = concat(
    [aws_security_group.this.id],
    var.additional_security_group_ids
  )
}

resource "aws_lambda_function" "this" {
  function_name = var.function_name

  filename = "${path.module}/handler/dist/handler.zip"
  handler  = "handler.handle"
  runtime  = "python3.8"

  environment {
    variables = {
      "PG_HOST"         = var.pg_connection_config["host"]
      "PG_PASSWORD_KEY" = local.pg_password_key
      "PG_PORT"         = var.pg_connection_config["port"]
      "PG_USER"         = var.pg_connection_config["user"]
    }
  }

  layers = [aws_lambda_layer_version.this.arn]

  role = aws_iam_role.this.arn

  vpc_config {
    security_group_ids = local.security_group_ids
    subnet_ids         = var.subnet_ids
  }

  timeout = 10 # Allow 10 second timeout rather than default of 3

  tags = var.tags

  lifecycle {
    ignore_changes = [
      filename,
      source_code_hash,
      source_code_size,
    ]
  }
}

resource "aws_lambda_layer_version" "this" {
  filename   = "${path.module}/layer/dist/layer.zip"
  layer_name = var.function_name

  compatible_runtimes = ["python3.8"]
}

data "aws_subnet" "selected" {
  id = var.subnet_ids[0]
}

resource "aws_security_group" "this" {
  name        = var.function_name
  description = var.function_name
  tags        = var.tags
  vpc_id      = data.aws_subnet.selected.vpc_id
}

# Allow the lambda outbound HTTPS to connect to the AWS APIs
resource "aws_security_group_rule" "https" {
  security_group_id = aws_security_group.this.id
  type              = "egress"
  protocol          = "tcp"
  to_port           = 443
  from_port         = 443
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

resource "aws_ssm_parameter" "pg_password_key" {
  name  = local.pg_password_key
  type  = "SecureString"
  value = "CHANGEME"

  lifecycle {
    ignore_changes = [value, version]
  }
}
