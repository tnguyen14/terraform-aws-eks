provider "aws" {
  version = ">= 2.28.1"
  region  = var.aws_region
}

provider "local" {
  version = "~> 1.2"
}

provider "null" {
  version = "~> 2.1"
}

provider "template" {
  version = "~> 2.1"
}
