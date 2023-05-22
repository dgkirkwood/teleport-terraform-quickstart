terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = var.region
}

provider "aws" {
  #Required for creating the ACM certificate
  alias = "us-east-1"
  region = "us-east-1"
}