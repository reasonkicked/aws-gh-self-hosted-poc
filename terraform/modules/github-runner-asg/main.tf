data "aws_iam_openid_connect_provider" "github" { url = "https://token.actions.githubusercontent.com" }

data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "main" {
  name               = "${var.fleet_name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}
resource "aws_iam_role" "extra" {
  count              = length(var.additional_role_names)
  name               = var.additional_role_names[count.index]
  assume_role_policy = data.aws_iam_policy_document.assume.json
}
resource "aws_iam_instance_profile" "runner" {
  name = "${var.fleet_name}-profile"
  roles = concat([aws_iam_role.main.name], aws_iam_role.extra[*].name)
}
resource "aws_launch_template" "runner" {
  name_prefix           = "${var.fleet_name}-lt-"
  image_id              = var.ami_id
  instance_type         = var.instance_type
  iam_instance_profile { name = aws_iam_instance_profile.runner.name }
  user_data             = base64encode(templatefile("${path.module}/runner-init.sh.tpl", { labels = join(",", var.labels) }))
}
module "asg" {
  source              = "terraform-aws-modules/autoscaling/aws"
  name                = var.fleet_name
  launch_template     = { id = aws_launch_template.runner.id, version = "$Latest" }
  min_size            = 0
  max_size            = 2
  desired_capacity    = 0
  vpc_zone_identifier = var.subnet_ids
  lifecycle { ignore_changes = [desired_capacity] }
}