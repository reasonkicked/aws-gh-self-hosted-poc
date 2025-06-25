terraform {
  required_version = ">= 1.6.6"
  required_providers { aws = { source = "hashicorp/aws", version = "~> 5.45.0" } }
  backend "s3" { bucket = "shared-services-state-prod" key = "terraform.tfstate" region = "eu-west-1" }
}
provider "aws" { region = "eu-west-1" }
module "network" { source = "../../modules/network" cidr_block = "10.0.0.0/16" }
module "wiv_runners" { source = "../../modules/github-runner-asg" fleet_name = "wiv-prod" ami_id = var.runner_ami_id subnet_ids = module.network.public_subnet_ids labels = ["wiv","prod"] additional_role_names = ["ssm-access","cw-logs"] }
module "ch_runners"  { source = "../../modules/github-runner-asg" fleet_name = "cloudhealth-prod" ami_id = var.runner_ami_id subnet_ids = module.network.public_subnet_ids labels = ["cloudhealth","prod"] additional_role_names = ["ssm-access","cw-logs"] }