# ================================================================
# Config
# ================================================================

terraform {
  required_version = "~> 1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.72"
    }
  }

  backend "s3" {
    bucket         = "<bucket>"
    key            = "<key>"
    dynamodb_table = "<table>"
    region         = "<region>"
  }
}

# ================================================================
# Provider
# ================================================================

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      SystemName = var.system_name
    }
  }
}

# ================================================================
# Modules
# ================================================================

module "common" {
  source = "./terraform_modules/common"

  system_name = var.system_name
  region      = var.region

  slack_incoming_webhook_error_notifier_01 = var.SLACK_INCOMING_WEBHOOK_ERROR_NOTIFIER_01
}

# ================================================================
# Variables
# ================================================================

variable "system_name" {
  type     = string
  nullable = false
}

variable "region" {
  type     = string
  nullable = false
}

variable "SLACK_INCOMING_WEBHOOK_ERROR_NOTIFIER_01" {
  type     = string
  nullable = false
}
