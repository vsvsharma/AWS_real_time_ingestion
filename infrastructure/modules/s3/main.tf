/*
creating the bucket to store the output of the firehose i.e. raw-layer-bucket
*/

resource "aws_s3_bucket" "firehose_bucket" {
  bucket = var.s3_bucket_name
}

/* enabling the versioning for the s3 bucket 
for incase if data gets delete then we can retrive the data
*/
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.firehose_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

/* creating s3 bucket for the transform layer 
and making object as the tables to store the data efficiently
*/
resource "aws_s3_bucket" "transform_bucket" {
  bucket = var.s3_transform_bucket
}

resource "aws_s3_object" "personal_details" {
  bucket = aws_s3_bucket.transform_bucket.bucket
  key = "personal_details/"
}

resource "aws_s3_object" "address" {
  bucket = aws_s3_bucket.transform_bucket.bucket
  key = "address/"
}

resource "aws_s3_object" "picture" {
  bucket = aws_s3_bucket.transform_bucket.bucket
  key = "picture/"
}

resource "aws_s3_object" "login" {
  bucket = aws_s3_bucket.transform_bucket.bucket
  key = "login/"
}

resource "aws_s3_object" "location" {
  bucket = aws_s3_bucket.transform_bucket.bucket
  key = "location/"
}

resource "aws_s3_object" "registration" {
  bucket = aws_s3_bucket.transform_bucket.bucket
  key = "registration/"
}

resource "aws_s3_object" "encrypted_details" {
  bucket = aws_s3_bucket.transform_bucket.bucket
  key = "encrypted_details/"
}

resource "aws_s3_bucket" "glue_job_bucket" {
  bucket = var.glue_job_bucket
}

#uploading the transformation glue job into the s3 glue job bucket 
resource "aws_s3_object" "my_file" {
  bucket = aws_s3_bucket.glue_job_bucket.bucket
  key    = "transformation_glue_job.py"  # S3 object key (file name and path within the bucket)
  source = "/home/varuns/personal/AWS_real_time_ingestion/code/transformation_glue_job.py"  # Local path to the file want to upload
  acl    = "private"
}

