provider "aws" {
  region = "sa-east-1"
}

resource "aws_s3_bucket" "devops_bucket" {
  bucket = "devops-fase2-bucket"
  force_destroy = true
}

