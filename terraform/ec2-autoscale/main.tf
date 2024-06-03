##########################
#     Naming Config      #
##########################
module "resource_name_prefix" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/resource-name-prefix/aws"
  version = "0.0.1"

  name = var.name
  tags = var.tags
}

##########################
#   Launch Template      #
##########################
resource "aws_launch_template" "ec2_lt" {
  name_prefix   = "${module.resource_name_prefix.resource_name}-lt"
  image_id      = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = var.security_group_ids

  user_data = base64encode(var.user_data)

  iam_instance_profile {
    arn = var.iam_instance_profile
  }

  monitoring {
    enabled = var.detailed_monitoring
  }

  # Propagate tags to additonal resource created by the launch template
  dynamic "tag_specifications" {
    for_each = {
      "network-interface" = "-ec2-ni",
      # "instance"          = "-ec2",
      "volume" = "-ec2-vol"
    }
    content {
      resource_type = tag_specifications.key
      tags = merge(
        var.tags,
        { "Name" = "${module.resource_name_prefix.resource_name}${tag_specifications.value}" }
      )
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

##########################
#   Auto Scaling Group   #
##########################
resource "aws_autoscaling_group" "ec2_asg" {
  name_prefix = "${module.resource_name_prefix.resource_name}-asg"

  launch_template {
    id      = aws_launch_template.ec2_lt.id
    version = "$Latest"
  }

  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity
  vpc_zone_identifier = var.vpc_zone_identifiers
  target_group_arns   = var.target_group_arns

  tag {
    key                 = "Name"
    value               = "${module.resource_name_prefix.resource_name}-ec2"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}