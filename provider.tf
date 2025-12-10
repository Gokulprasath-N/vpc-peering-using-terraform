terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}



# Provider for the primary region (us-east-1)
provider "aws" {
  region = var.first_region
  alias  = "first_VPC"
}

# Provider for the secondary region (us-west-2)
provider "aws" {
  region = var.second_region
  alias  = "second_VPC"
}

provider "aws" {
  region = var.third_region
  alias  = "third_VPC"
}