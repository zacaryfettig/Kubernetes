resource "random_id" "random" {
  byte_length = 8
}

locals {
  bastionFilesBucketName = "bastionfiles-${random_id.random.hex}"
}

resource "aws_s3_bucket" "bastionFiles" {
  bucket = local.bastionFilesBucketName
}

resource "aws_s3_object" "nextCloudSecret" {
  bucket = aws_s3_bucket.bastionFiles.bucket
  key = "nextcloudSecret.yaml"
  source = "./kubernetes/nextcloudSecret.yaml"
  depends_on = [ aws_s3_bucket.bastionFiles ]
}