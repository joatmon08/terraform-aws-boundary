module "iam" {
  source = "./modules/iam"
  name   = var.name
  tags   = local.tags
}

resource "aws_iam_role_policy" "boundary" {
  name = "${var.name}-boundary"
  role = module.iam.iam_role.id

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
  role = module.iam.iam_role.id

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