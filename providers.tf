terraform {
  backend "s3" {
    bucket         = "clickhouse-ec2-terraform-state"
    key            = "terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "clickhouse-ec2-terraform"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.20.1"
    }
  }
}

provider "aws" {
  region                  = var.aws_region
  skip_metadata_api_check = true
}
