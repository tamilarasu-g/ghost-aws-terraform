resource "aws_iam_role" "a-record-role" {
  name = "create-a-record-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name   = "create-a-record-policy"
    policy = file(var.a-record-policy-path)
  }
}

resource "aws_iam_role" "create-volume-instance-role" {
  name = "create-volume-start-instance-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name   = "create-volume-start-instance-policy"
    policy = file(var.volume-start-instance-policy-path)
  }
}

resource "aws_iam_role" "snap-and-delete-volume-role" {
  name = "snap-and-delete-volume-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name   = "snap-and-delete-volume-policy"
    policy = file(var.snap-and-delete-volume-policy-path)
  }
}