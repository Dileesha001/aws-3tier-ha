import {
  to = aws_iam_role.ec2
  id = "three-tier-ec2-role"
}

import {
  to = aws_iam_instance_profile.ec2
  id = "three-tier-ec2-role"
}

import {
  to = aws_iam_role_policy.secret
  id = "three-tier-ec2-role:ReadRequiredAppSecret"
}

import {
  to = aws_iam_role_policy_attachment.ssm
  id = "three-tier-ec2-role/arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

import {
  to = aws_iam_role_policy_attachment.logs
  id = "three-tier-ec2-role/arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

import {
  to = aws_launch_template.app
  id = "lt-066a25789b97f1cce"
}

import {
  to = aws_autoscaling_group.app
  id = "three-tier-app-asg"
}

import {
  to = aws_autoscaling_policy.cpu
  id = "three-tier-app-asg/cpu-target-55"
}

import {
  to = aws_db_instance.app
  id = "database-1"
}

import {
  to = aws_db_subnet_group.app
  id = "three-tier-db-subnet-group"
}

import {
  to = aws_cloudwatch_log_group.access
  id = "/three-tier/nginx/access"
}

import {
  to = aws_cloudwatch_log_group.error
  id = "/three-tier/nginx/error"
}

import {
  to = aws_cloudwatch_metric_alarm.healthy
  id = "three-tier-healthy-targets-low"
}

import {
  to = aws_sns_topic.alerts
  id = "arn:aws:sns:ap-southeast-2:802823597623:three-tier-alerts"
}

import {
  to = aws_budgets_budget.spending
  id = "802823597623:three-tier-spending-alert"
}


import {
  to = aws_sns_topic_subscription.email
  id = "arn:aws:sns:ap-southeast-2:802823597623:three-tier-alerts:b62c37c1-5c6c-4348-b09b-0a556db151a4"
}
