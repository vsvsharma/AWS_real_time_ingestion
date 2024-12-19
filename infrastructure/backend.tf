resource "aws_s3_bucket" "state_file" {
    bucket = "terraform-state-file-user-data-infra"
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.state_file.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "state_lock" {
  name = "state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}