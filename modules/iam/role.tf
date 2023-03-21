resource "aws_iam_role" "boundary" {
  name = var.name
  path = "/${var.name}/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = var.tags
}

resource "aws_iam_instance_profile" "boundary" {
  name = var.name
  role = aws_iam_role.boundary.name
}