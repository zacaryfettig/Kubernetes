terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.43.0"
    }
  }
}

provider "aws" {
    region = "us-west-2"
    access_key = ""
    secret_key = ""
}

provider "random" {
}
