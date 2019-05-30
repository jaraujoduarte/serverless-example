terraform {
  backend "s3" {
    bucket = "playground-remote-state"
    key    = "serverless-example-backend.tf"
    region = "us-east-1"
  }
}
