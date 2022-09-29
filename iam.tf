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

  tags = local.tags
}

resource "aws_iam_instance_profile" "boundary" {
  name = var.name
  role = aws_iam_role.boundary.name
}

resource "aws_iam_role_policy" "boundary" {
  name = "${var.name}-boundary"
  role = aws_iam_role.boundary.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Action": [
      "kms:DescribeKey",
      "kms:GenerateDataKey",
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:ListKeys",
      "kms:ListAliases"
    ],
    "Resource": [
      "${aws_kms_key.root.arn}",
      "${aws_kms_key.worker_auth.arn}",
      "${aws_kms_key.recovery.arn}"
    ]
  }
}
EOF
}

resource "aws_iam_role_policy" "boundary_host_catalog" {
  name = "${var.name}-host-catalog-plugin"
  role = aws_iam_role.boundary.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:DescribeInstances"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}