# ------------------------------------------------------------------------------
# S3 server access logging target for the CloudTrail bucket (AVD-AWS-0163, CIS).
#
# Only the CloudTrail bucket logs here: it holds the audit trail, so knowing
# who read/deleted objects has forensic value. The other buckets deliberately
# skip server access logging (see .trivyignore AVD-AWS-0089) — CloudTrail
# already records API access to them, and logging the log bucket itself is
# circular.
# ------------------------------------------------------------------------------

resource "aws_s3_bucket" "cloudtrail_access_logs" {
  bucket        = var.cloudtrail_access_logs_bucket_name
  force_destroy = false

  lifecycle {
    prevent_destroy = true
  }

  tags = merge(var.common_tags, {
    Name = var.cloudtrail_access_logs_bucket_name
  })
}

resource "aws_s3_bucket_ownership_controls" "cloudtrail_access_logs" {
  bucket = aws_s3_bucket.cloudtrail_access_logs.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "cloudtrail_access_logs" {
  bucket                  = aws_s3_bucket.cloudtrail_access_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail_access_logs" {
  bucket = aws_s3_bucket.cloudtrail_access_logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "cloudtrail_access_logs" {
  bucket = aws_s3_bucket.cloudtrail_access_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "cloudtrail_access_logs" {
  bucket = aws_s3_bucket.cloudtrail_access_logs.id

  rule {
    id     = "expire-logs-90-days"
    status = "Enabled"

    filter {
      prefix = ""
    }

    expiration {
      days = 90
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

# BucketOwnerEnforced disables ACLs, so the S3 log delivery group cannot be
# granted via ACL — the modern logging.s3.amazonaws.com service principal
# needs an explicit bucket policy instead.
data "aws_iam_policy_document" "cloudtrail_access_logs" {
  statement {
    sid    = "S3ServerAccessLogsPolicy"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }

    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.cloudtrail_access_logs.arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.cloudtrail_logs.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "cloudtrail_access_logs" {
  bucket = aws_s3_bucket.cloudtrail_access_logs.id
  policy = data.aws_iam_policy_document.cloudtrail_access_logs.json
}
