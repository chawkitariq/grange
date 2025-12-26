# S3 Bucket for Training Data and Model Artifacts
resource "aws_s3_bucket" "ml_data" {
  bucket = local.name_prefix
  force_destroy = true
}

resource "aws_s3_object" "input_folder" {
  bucket = aws_s3_bucket.ml_data.id
  key    = "input/"
  content = ""
}

resource "aws_s3_object" "output_folder" {
  bucket = aws_s3_bucket.ml_data.id
  key    = "output/"
  content = ""
}

resource "aws_s3_bucket_server_side_encryption_configuration" "ml_data" {
  bucket = aws_s3_bucket.ml_data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "ml_data" {
  bucket = aws_s3_bucket.ml_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

