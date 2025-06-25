terraform {
  required_version = ">= 1.6.6"
  required_providers { aws = { source = "hashicorp/aws", version = "~> 5.45.0" } }
  backend "s3" { bucket = "shared-services-state-prod" key = "terraform.tfstate" region = "eu-west-1" }
}
provider "aws" { region = "eu-west-1" }

data "aws_ami" "runner" {
  most_recent = true
  owners      = ["self"]
  filter {
    name   = "name"
    values = ["gh-runner-*"]
  }
}

module "network" {
  source     = "../../modules/network"
  cidr_block = "10.0.0.0/16"
}

module "wiv_runners" {
  source        = "../../modules/github-runner-asg"
  fleet_name    = "wiv-prod"
  ami_id        = data.aws_ami.runner.id
  subnet_ids    = module.network.public_subnet_ids
  labels        = ["self-hosted","aws","wiv","prod"]
  additional_role_names = ["ssm-access","cw-logs"]
}

module "cloudhealth_runners" {
  source        = "../../modules/github-runner-asg"
  fleet_name    = "cloudhealth-prod"
  ami_id        = data.aws_ami.runner.id
  subnet_ids    = module.network.public_subnet_ids
  labels        = ["self-hosted","aws","cloudhealth","prod"]
  additional_role_names = ["ssm-access","cw-logs"]
}