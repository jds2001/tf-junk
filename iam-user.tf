
resource "aws_iam_user" "example_user" {
  name = "example-user"
  path = "/somepath/"
}

data "aws_iam_policy_document" "allow_assume_role" {
  statement {
    actions   = ["sts:AssumeRole"]
    effect    = "Allow"
    resources = ["${aws_iam_role.test_role.arn}"]
    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = ["98.109.4.95"]
    }
  }
}

resource "aws_iam_policy" "example_policy" {
  name        = "example-policy"
  description = "Policy allowing assume role"
  policy      = data.aws_iam_policy_document.allow_assume_role.json
}

resource "aws_iam_policy" "second_policy" {
  name        = "second-policy"
  description = "Policy allowing S3 read access"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::example-bucket/*"
        }
    ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "example_attachment" {
  user       = aws_iam_user.example_user.name
  policy_arn = aws_iam_policy.example_policy.arn
}

resource "aws_iam_user_policy_attachment" "second_attachment" {
  user       = aws_iam_user.example_user.name
  policy_arn = aws_iam_policy.second_policy.arn
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["${aws_iam_user.example_user.arn}"]
    }
    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = ["98.109.4.95"]
    }
  }
}

data "aws_iam_policy_document" "test-policy-document" {
  statement {
    actions   = ["ec2:GetLaunchTemplateData"]
    resources = ["*"]
  }

  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::example-bucket/*"]
  }

}

data "aws_iam_policy_document" "test-policy-document-2" {
  statement {
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::example-bucket"]
  }

  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::example-bucket/*"]
  }

}

resource "aws_iam_policy" "test-policy" {
  name        = "test-policy"
  description = "Test policy for S3 access"
  policy      = data.aws_iam_policy_document.test-policy-document.json
}

resource "aws_iam_policy" "test-policy-2" {
  name        = "test-policy-2"
  description = "Test policy for S3 access"
  policy      = data.aws_iam_policy_document.test-policy-document-2.json
}

resource "aws_iam_role" "test_role" {
  name               = "test-role2"
  path               = "/somepath7/"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  force_detach_policies = true

}

resource "aws_iam_role_policy_attachment" "test_role_attachment" {
  role       = aws_iam_role.test_role.name
  policy_arn = aws_iam_policy.example_policy.arn
}

resource "aws_iam_role_policy_attachment" "test_role_attachment_2" {
  role       = aws_iam_role.test_role.name
  policy_arn = aws_iam_policy.second_policy.arn

}
