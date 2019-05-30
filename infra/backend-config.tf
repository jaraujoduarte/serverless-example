terraform {
  backend "s3" {
    bucket = "playground-remote-state"
    key    = "serverless-example.tfstate"
    region = "us-east-1"
  }
}
