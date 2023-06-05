terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }

}

provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {}
