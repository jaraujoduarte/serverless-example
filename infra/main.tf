provider "aws" {
  version = "~> 2.0"
  region  = "us-east-1"
}

resource "aws_dynamodb_table" "movie" {
  name         = "movie"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "N"
  }

  tags = {
    group = "serverless-example"
  }
}

resource "aws_dynamodb_table" "rating" {
  name         = "rating"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    group = "serverless-example"
  }
}

# Website
resource "aws_s3_bucket" "website" {
  bucket = var.domain
  acl    = "public-read"
  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"",
      "Effect":"Allow",
      "Principal": "*",
      "Action":["s3:GetObject"],
      "Resource":["arn:aws:s3:::${var.domain}/*"]
    }
  ]
}
POLICY

  website {
    index_document = "index.html"
  }
}

# Cloudfront
locals {
  s3_origin_id = "serverless-example-origin"
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "Serverless example identity"
}

resource "aws_cloudfront_distribution" "s3_website_distribution" {
  origin {
    domain_name = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = false
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${local.s3_origin_id}"

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    group = "serverless-example"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# API gateway
resource "aws_api_gateway_rest_api" "serverless_example" {
  name = "serverless-example"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}
