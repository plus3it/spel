data "aws_caller_identity" "current" {}

resource "aws_iam_role" "spel-codebuild-role" {
  name = "${var.project_name}-codebuild"
  path = "/service-role/"

  assume_role_policy = <<-POLICY
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
            "Service": "codebuild.amazonaws.com"
          },
          "Action": "sts:AssumeRole"
        }
      ]
    }
    POLICY
}

resource "aws_iam_role_policy" "packer-codebuild-permissions" {
  name = "packer-codebuild-permissions"
  role = "${aws_iam_role.spel-codebuild-role.name}"

  policy = <<-POLICY
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Resource": [
                    "arn:aws:logs:us-east-1:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/spel-ci",
                    "arn:aws:logs:us-east-1:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/spel-ci:*"
                ],
                "Action": [
                    "logs:CreateLogGroup",
                    "logs:CreateLogStream",
                    "logs:PutLogEvents"
                ]
            },
            {
                "Effect": "Allow",
                "Resource": [
                    "arn:aws:s3:::spel-ci/*"
                ],
                "Action": [
                    "s3:PutObject"
                ]
            }
        ]
    }
    POLICY
}

resource "aws_iam_role_policy" "packer-ec2-permissions" {
  name = "packer-ec2-permissions"
  role = "${aws_iam_role.spel-codebuild-role.name}"

  policy = <<-POLICY
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "ec2:AttachVolume",
                    "ec2:AuthorizeSecurityGroupIngress",
                    "ec2:CopyImage",
                    "ec2:CreateImage",
                    "ec2:CreateKeypair",
                    "ec2:CreateSecurityGroup",
                    "ec2:CreateSnapshot",
                    "ec2:CreateTags",
                    "ec2:CreateVolume",
                    "ec2:DeleteKeypair",
                    "ec2:DeleteSecurityGroup",
                    "ec2:DeleteSnapshot",
                    "ec2:DeleteVolume",
                    "ec2:DeregisterImage",
                    "ec2:DescribeImageAttribute",
                    "ec2:DescribeImages",
                    "ec2:DescribeInstances",
                    "ec2:DescribeInstanceStatus",
                    "ec2:DescribeRegions",
                    "ec2:DescribeSecurityGroups",
                    "ec2:DescribeSnapshots",
                    "ec2:DescribeSubnets",
                    "ec2:DescribeTags",
                    "ec2:DescribeVolumes",
                    "ec2:DetachVolume",
                    "ec2:GetPasswordData",
                    "ec2:ModifyImageAttribute",
                    "ec2:ModifyInstanceAttribute",
                    "ec2:ModifySnapshotAttribute",
                    "ec2:RegisterImage",
                    "ec2:RunInstances",
                    "ec2:StopInstances",
                    "ec2:TerminateInstances"
                ],
                "Resource": "*"
            }
        ]
    }
    POLICY
}

data "aws_kms_key" "ssm_key" {
  key_id = "alias/${var.ssm_key_name}"
}

resource "aws_iam_role_policy" "packer-ssm-permissions" {
  name = "packer-ssm-permissions"
  role = "${aws_iam_role.spel-codebuild-role.name}"

  policy = <<-POLICY
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "AllowSsmGetParameters",
                "Effect": "Allow",
                "Action": [
                    "ssm:GetParameters"
                ],
                "Resource": "arn:aws:ssm:*:*:parameter/spel/*"
            },
            {
                "Sid": "AllowKmsDecrypt",
                "Effect": "Allow",
                "Action": [
                    "kms:Decrypt"
                ],
                "Resource": "arn:aws:kms:*:*:key/${data.aws_kms_key.ssm_key.id}"
            }
        ]
    }
    POLICY
}

output "role_arn" {
  description = "ARN of the created role"
  value       = "${aws_iam_role.spel-codebuild-role.arn}"
}
