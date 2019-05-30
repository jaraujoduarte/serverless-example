
data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket = "playground-remote-state"
    key    = "serverless-example.tfstate"
    region = "${var.region}"
  }
}

