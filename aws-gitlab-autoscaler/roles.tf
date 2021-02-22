# for the autoscaler + the runners

data "aws_iam_policy_document" "trust_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

## for the autoscaler aka 'Bastion'

resource "aws_iam_role" "bastion_instance_role" {
  name = "${title(var.name)}-Bastion-Role"

  assume_role_policy = "${data.aws_iam_policy_document.trust_policy_document.json}"
}

data "aws_iam_policy_document" "bastion_policy_document" {
  statement {
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
    ]

    resources = [
      "${format("arn:aws:s3:::%s", aws_s3_bucket.gitlab_runner_cache.id)}",
    ]
  }

  statement {
    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:PutObject",
    ]

    resources = [
      "${format("arn:aws:s3:::%s/*", aws_s3_bucket.gitlab_runner_cache.id)}",
    ]
  }

  statement {
    actions = [
      "ec2:CreateKeyPair",
      "ec2:DeleteKeyPair",
      "ec2:ImportKeyPair",
      "ec2:Describe*",
      "ec2:CreateTags",
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "ec2:RunInstances",
    ]

    resources = [
      "arn:aws:ec2:eu-west-1::image/ami-*",
      "arn:aws:ec2:eu-west-1:${data.aws_caller_identity.current.account_id}:instance/*",
      "arn:aws:ec2:eu-west-1:${data.aws_caller_identity.current.account_id}:key-pair/*",
      "arn:aws:ec2:eu-west-1:${data.aws_caller_identity.current.account_id}:network-interface/*",
      "arn:aws:ec2:eu-west-1:${data.aws_caller_identity.current.account_id}:placement-group/*",
      "arn:aws:ec2:eu-west-1:${data.aws_caller_identity.current.account_id}:security-group/*",
      "arn:aws:ec2:eu-west-1:${data.aws_caller_identity.current.account_id}:subnet/*",
      "arn:aws:ec2:eu-west-1:${data.aws_caller_identity.current.account_id}:volume/*",
    ]
  }

  statement {
    actions = [
      "ec2:TerminateInstances",
      "ec2:StopInstances",
      "ec2:StartInstances",
      "ec2:RebootInstances",
      "ec2:CreateSecurityGroup",
      "ec2:AuthorizeSecurityGroupIngress",
    ]

    resources = [
      "arn:aws:ec2:eu-west-1:${data.aws_caller_identity.current.account_id}:instance/*",
    ]
  }

  statement {
    actions = [
      "iam:GetRole",
      "iam:PassRole",
    ]

    resources = [
      "${aws_iam_role.machine_instance_role.arn}",
    ]
  }
}

resource "aws_iam_policy" "bastion_policy" {
  name   = "${title(var.name)}-Bastion-Policy"
  policy = "${data.aws_iam_policy_document.bastion_policy_document.json}"
}

resource "aws_iam_role_policy_attachment" "bastion_policy_attachment" {
  role       = "${aws_iam_role.bastion_instance_role.name}"
  policy_arn = "${aws_iam_policy.bastion_policy.arn}"
}

resource "aws_iam_instance_profile" "bastion_instance_profile" {
  name = "${title(var.name)}-Bastion-Profile"
  role = "${aws_iam_role.bastion_instance_role.name}"
}

## for the runners aka 'Machine'

resource "aws_iam_role" "machine_instance_role" {
  name = "${title(var.name)}-Machine-Role"

  assume_role_policy = "${data.aws_iam_policy_document.trust_policy_document.json}"
}

data "aws_iam_policy_document" "machine_policy_document" {
  statement {
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
    ]

    resources = [
      "${format("arn:aws:s3:::%s", aws_s3_bucket.gitlab_runner_cache.id)}",
      "${formatlist("arn:aws:s3:::%s", var.additional_s3_buckets)}",
    ]
  }

  statement {
    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:PutObject",
    ]

    resources = [
      "${format("arn:aws:s3:::%s/*", aws_s3_bucket.gitlab_runner_cache.id)}",
      "${formatlist("arn:aws:s3:::%s/*", var.additional_s3_buckets)}",
    ]
  }

  statement {
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    actions   = ["ec2:CreateImage"]
    resources = ["*"]
  }

  statement {
    actions = [
      "ec2:DescrbeInstances",
      "ec2:DescribeInstanceStatus",
      "ec2:DescribeImages",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:DescribeRegions",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CopyImage",
      "ec2:CreateImage",
      "ec2:CreateKeypair",
      "ec2:CreateSnapshot",
      "ec2:CreateVolume",
      "ec2:DeleteKeyPair",
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
      "ec2:ModifyImageAttribute",
      "ec2:ModifyInstanceAttribute",
      "ec2:ModifySnapshotAttribute",
      "ec2:RegisterImage",
      "ec2:RunInstances",
      "ec2:CreateTags",
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "ec2:CreateSecurityGroup",
      "ec2:DeleteSecurityGroup",
      "ec2:RevokeSecurityGroupIngress",
    ]

    resources = ["*"]

    condition {
      test     = "StringLike"
      variable = "ec2:SecurityGroupName"
      values   = ["Packer-*"]
    }
  }

  statement {
    actions = [
      "ec2:StartInstances",
      "ec2:StopInstances",
      "ec2:TerminateInstances",
      "ec2:GetPasswordData",
      "ec2:DeleteSnapshot",
      "ec2:DeleteVolume",
      "ec2:TerminateInstances",
      "ec2:DetachVolume",
      "ec2:AttachVolume",
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/Role"
      values   = ["Packer"]
    }
  }
}

resource "aws_iam_policy" "machine_policy" {
  name   = "${title(var.name)}-Machine-Policy"
  policy = "${data.aws_iam_policy_document.machine_policy_document.json}"
}

resource "aws_iam_role_policy_attachment" "machine_policy_attachment" {
  role       = "${aws_iam_role.machine_instance_role.name}"
  policy_arn = "${aws_iam_policy.machine_policy.arn}"
}

resource "aws_iam_instance_profile" "machine_instance_profile" {
  name = "${title(var.name)}-Machine-Profile"
  role = "${aws_iam_role.machine_instance_role.name}"
}
