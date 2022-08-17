# Day 2 basic setup of self hosted Teleport
# 2 server setup using https://goteleport.com/docs/server-access/getting-started/

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
  region  = "ap-southeast-2"
}