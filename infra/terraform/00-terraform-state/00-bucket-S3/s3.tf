# Bucket para estado remoto de Terraform
resource "aws_s3_bucket" "tf_state" {
  bucket        = var.state_bucket_name
  force_destroy = false

  lifecycle {
    prevent_destroy = true
  }

  tags = merge(var.common_tags, {
    Name = var.state_bucket_name
    Role = "terraform-state"
  })
}

# Enforzar propiedad del bucket (sin ACLs)
resource "aws_s3_bucket_ownership_controls" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Bloqueo de acceso público
resource "aws_s3_bucket_public_access_block" "tf_state" {
  bucket                  = aws_s3_bucket.tf_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Versionado obligatorio para historial de tfstate
resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Cifrado del lado del servidor (SSE-S3).
resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Lifecycle para controlar versiones antiguas del tfstate
resource "aws_s3_bucket_lifecycle_configuration" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    id     = "retain-tfstate-history"
    status = "Enabled"

    # Aplica a todo el bucket
    filter {
      prefix = ""
    }

    # Transición de versiones NO actuales: barato y rápido de recuperar
    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "GLACIER_IR"
    }

    # Aún más barato (recuperación lenta)
    noncurrent_version_transition {
      noncurrent_days = 120
      storage_class   = "DEEP_ARCHIVE"
    }

    # Expira versiones NO actuales pasados 365 días,
    # conservando al menos 10 versiones más recientes
    noncurrent_version_expiration {
      noncurrent_days           = 365
      newer_noncurrent_versions = 10
    }

    # Higiene: abortar subidas multipart sin finalizar
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# Requerir TLS (bloquear peticiones sin HTTPS)
data "aws_iam_policy_document" "require_tls" {
  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.tf_state.arn,
      "${aws_s3_bucket.tf_state.arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  policy = data.aws_iam_policy_document.require_tls.json
}
