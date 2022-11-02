terraform {
  required_version = "~> 1.2.4"
}

terraform {
  required_providers {
    archive = {
      source = "hashicorp/archive"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.37.0"
    }
    null = {
      source = "hashicorp/null"
    }
    template = {
      source = "hashicorp/template"
    }
    local = {
      source = "hashicorp/local"
    }
  }
}

# The "default" instance of the provider used to provision resources
provider "aws" {
  region = var.DEFAULT_REGION
}

# The us-east-1 provider used to provision ACM cert and R53 HZ (must have alias us-east-1)
provider "aws" {
  region = "us-east-1"
  alias  = "us-east-1"
}

terraform {
  backend "s3" {
  }
}

locals {
  published_packages = jsondecode(file("${path.module}/../properties/published-packages.json"))
}
