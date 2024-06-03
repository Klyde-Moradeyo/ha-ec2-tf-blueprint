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
  image_id      = var.instance_types_config[var.default_instance_type].ami
  instance_type = var.default_instance_type
  key_name      = var.key_name

  vpc_security_group_ids = var.security_group_ids
  user_data = base64encode(var.user_data)

  iam_instance_profile {
    arn = var.iam_instance_profile
  }

  monitoring {
    enabled = var.detailed_monitoring
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

  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity
  vpc_zone_identifier = var.vpc_zone_identifiers
  target_group_arns   = var.target_group_arns

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                = var.spot_configuration.enabled ? var.spot_configuration.on_demand_base_capacity : var.desired_capacity
      on_demand_percentage_above_base_capacity = var.spot_configuration.enabled ? var.spot_configuration.on_demand_percentage_above_base_capacity : 100
      spot_allocation_strategy               = var.spot_configuration.enabled ? var.spot_configuration.allocation_strategy : null
      spot_instance_pools                    = var.spot_configuration.enabled ? var.spot_configuration.instance_pools : null
      spot_max_price                         = var.spot_configuration.enabled ? var.spot_configuration.max_price : null                    
    }

    launch_template {
      launch_template_specification {
        launch_template_id   = aws_launch_template.ec2_lt.id
        version              = "$Latest"
      }

      override {
        instance_type     = var.default_instance_type
        weighted_capacity = var.instance_types_config[var.default_instance_type].weighted_capacity
      }

      dynamic "override" {
        for_each = var.instance_type_overrides
        content {
          instance_type     = override.value
          weighted_capacity = var.instance_types_config[override.value].weighted_capacity
        }
      }
    }
  }

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

