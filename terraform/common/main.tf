terraform {
  required_version = ">= ${var.VERSION}"
}

terraform {
  required_providers {
    archive = {
      source = "hashicorp/archive"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> ${var.AWS_VERSION}"
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
  region = var.default_region
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

