variable "runner_version" {
  type    = string
  default = "2.316.0"
}

source "amazon-ebs" "runner" {
  region           = "eu-west-1"
  instance_type    = "t3.small"
  ami_name         = "gh-runner-{{timestamp}}"
  source_ami_filter {
    filters = {
      name                = "amzn2-ami-hvm-*-x86_64-gp2"
      virtualization-type  = "hvm"
      root-device-type     = "ebs"
    }
    owners      = ["137112412989"]
    most_recent = true
  }
}

build {
  sources = ["source.amazon-ebs.runner"]
  provisioner "shell" {
    inline = [
      "sudo yum update -y",
      "REG_TOKEN=$(curl -s -H 'Authorization: token $GH_TOKEN' https://api.github.com/orgs/$GH_ORG/actions/runners/registration-token | jq -r .token)",
      "/opt/actions/config.sh --url https://github.com/$GH_ORG --token $REG_TOKEN --labels self-hosted,aws,runner --unattended",
      "tar xzf actions-runner-linux-x64-${var.runner_version}.tar.gz -C /opt/actions",
      "sudo yum install -y jq unzip"
    ]
  }
}