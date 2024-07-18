resource "local_file" "create-a-record-lambda" {
  content = templatefile("${var.create-a-record-lambda-file}", {
    aws_required_region = var.aws-required-region,
    domain              = var.domain,
    instance-id         = var.instance-id
  })
  filename = "${path.module}/python/create-a-record.py"
}

data "archive_file" "create-a-record-zip" {
  type        = "zip"
  output_path = "${path.module}/python/create-a-record.zip"
  source_file = local_file.create-a-record-lambda.filename
}

resource "aws_lambda_function" "create-a-record-lambda" {
  filename      = "${path.module}/python/create-a-record.zip"
  runtime       = "python3.10"
  function_name = "create-a-record"
  role          = aws_iam_role.a-record-role.arn
  handler       = local_file.create-a-record-lambda.filename
  environment {
    variables = {
      NETLIFY_ACCESS_TOKEN = var.netlify_access_token
    }
  }
}

resource "local_file" "snap-and-delete-file" {
  content = templatefile("${var.snap-and-delete-volume-lambda-file}", {
    aws-required-region = var.aws-required-region,
    domain              = var.domain,
    instance-id         = var.instance-id
  })
  filename = "${path.module}/python/snap-and-delete-volume.py"
}

data "archive_file" "snap-and-delete-zip" {
  type        = "zip"
  output_path = "${path.module}/python/snap-and-delete-volume.zip"
  source_file = local_file.snap-and-delete-file.filename
}

resource "aws_lambda_function" "snap-and-delete-lambda" {
  filename      = "${path.module}/python/snap-and-delete-volume.zip"
  runtime       = "python3.10"
  function_name = "snap-and-delete-volume"
  role          = aws_iam_role.snap-and-delete-volume-role.arn
  handler       = local_file.snap-and-delete-file.filename
}

resource "local_file" "create-volume-instance" {
  content = templatefile("${var.create-volume-instance-lambda-file}", {
    aws-required-region = var.aws-required-region,
    domain              = var.domain,
    instance-id         = var.instance-id,
    root-device-name    = var.root-device-name
  })
  filename = "${path.module}/python/create-volume-instance.py"
}
data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/python/create-volume-instance.zip"
  source_file = local_file.create-volume-instance.filename
}

resource "aws_lambda_function" "create-volume-instance-lambda" {
  filename      = "${path.module}/python/create-volume-instance.zip"
  runtime       = "python3.10"
  function_name = "create-volume-start-instance"
  role          = aws_iam_role.create-volume-instance-role.arn
  handler       = local_file.create-volume-instance.filename
}



