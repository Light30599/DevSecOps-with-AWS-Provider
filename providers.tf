#######################MainConfig###########################
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.67.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }
  }
}

provider "aws" {
  # Configuration options
  region                   = "us-east-1"
  shared_credentials_files = ["~/.aws/credentials"]
  #profile                 = "user-ec2"
  default_tags {
    tags = {
      Environment = "Production"
      #Owner       = "Ops"
    }
  }
}