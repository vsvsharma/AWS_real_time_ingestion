terraform {
    backend "s3" {
      bucket = "terraform-state-file-user-data-infra"
      dynamodb_table = "state-lock"
      key = "Terraform/user-data-state-file/terraform.tfstate"
      region = "ap-south-1"
      encrypt = true
    }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.70.0"
    }
  }
}
 
provider "aws" {
  region = "ap-south-1"
}
