# ------------------------------------------------------------------------------
# CloudFront access logging — standard logging v2 (AVD-AWS-0010).
# ------------------------------------------------------------------------------

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "cf_access_logs" {
  bucket = var.cf_access_logs_bucket_name

  tags = merge(var.common_tags, {
    Name = var.cf_access_logs_bucket_name
  })
}

resource "aws_s3_bucket_ownership_controls" "cf_access_logs" {
  bucket = aws_s3_bucket.cf_access_logs.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "cf_access_logs" {
  bucket                  = aws_s3_bucket.cf_access_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cf_access_logs" {
  bucket = aws_s3_bucket.cf_access_logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "cf_access_logs" {
  bucket = aws_s3_bucket.cf_access_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "cf_access_logs" {
  bucket = aws_s3_bucket.cf_access_logs.id

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

data "aws_iam_policy_document" "cf_access_logs" {
  statement {
    sid    = "AWSLogDeliveryWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.cf_access_logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:logs:us-east-1:${data.aws_caller_identity.current.account_id}:delivery-source:*"]
    }
  }
}

resource "aws_s3_bucket_policy" "cf_access_logs" {
  bucket = aws_s3_bucket.cf_access_logs.id
  policy = data.aws_iam_policy_document.cf_access_logs.json
}

# --- Landing distribution ---

resource "aws_cloudwatch_log_delivery_source" "cf_landing" {
  provider = aws.us_east_1

  name         = "${var.project_name}-prod-cf-landing"
  log_type     = "ACCESS_LOGS"
  resource_arn = aws_cloudfront_distribution.prod_distribution_landing.arn

  tags = merge(var.common_tags, {
    Site = "landing"
  })
}

resource "aws_cloudwatch_log_delivery_destination" "cf_access_logs" {
  provider = aws.us_east_1

  name = "${var.project_name}-prod-cf-access-logs"

  delivery_destination_configuration {
    destination_resource_arn = aws_s3_bucket.cf_access_logs.arn
  }

  tags = var.common_tags
}

resource "aws_cloudwatch_log_delivery" "cf_landing" {
  provider = aws.us_east_1

  delivery_source_name     = aws_cloudwatch_log_delivery_source.cf_landing.name
  delivery_destination_arn = aws_cloudwatch_log_delivery_destination.cf_access_logs.arn

  depends_on = [aws_s3_bucket_policy.cf_access_logs]

  tags = merge(var.common_tags, {
    Site = "landing"
  })
}

# --- Academy distribution ---

resource "aws_cloudwatch_log_delivery_source" "cf_academy" {
  provider = aws.us_east_1

  name         = "${var.project_name}-prod-cf-academy"
  log_type     = "ACCESS_LOGS"
  resource_arn = aws_cloudfront_distribution.prod_distribution_academy.arn

  tags = merge(var.common_tags, {
    Site = "academy"
  })
}

resource "aws_cloudwatch_log_delivery" "cf_academy" {
  provider = aws.us_east_1

  delivery_source_name     = aws_cloudwatch_log_delivery_source.cf_academy.name
  delivery_destination_arn = aws_cloudwatch_log_delivery_destination.cf_access_logs.arn

  depends_on = [aws_s3_bucket_policy.cf_access_logs]

  tags = merge(var.common_tags, {
    Site = "academy"
  })
}
