output "name" {
  description = "Generated name from local configuration."
  value       = module.resource_name_prefix.resource_name
}

output "launch_template_id" {
  description = "The ID of the launch template."
  value       = aws_launch_template.ec2_lt.id
}

output "launch_template_name" {
  description = "The name of the launch template."
  value       = aws_launch_template.ec2_lt.name
}

output "autoscaling_group_name" {
  description = "The name of the Auto Scaling group."
  value       = aws_autoscaling_group.ec2_asg.name
}

output "autoscaling_group_arn" {
  description = "The ARN of the Auto Scaling group."
  value       = aws_autoscaling_group.ec2_asg.arn
}
