# __generated__ by Terraform
# Please review these resources and move them into your main configuration files.

# __generated__ by Terraform
resource "aws_autoscaling_policy" "cpu" {
  adjustment_type           = null
  autoscaling_group_name    = "three-tier-app-asg"
  cooldown                  = 0
  enabled                   = true
  estimated_instance_warmup = 600
  name                      = "cpu-target-55"
  policy_type               = "TargetTrackingScaling"
  region                    = "ap-southeast-2"
  scaling_adjustment        = 0
  target_tracking_configuration {
    disable_scale_in = false
    target_value     = 55
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
      resource_label         = null
    }
  }
}

# __generated__ by Terraform from "three-tier-ec2-role/arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
resource "aws_iam_role_policy_attachment" "ssm" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = "three-tier-ec2-role"
}

# __generated__ by Terraform from "three-tier-ec2-role"
resource "aws_iam_instance_profile" "ec2" {
  name     = "three-tier-ec2-role"
  path     = "/"
  role     = "three-tier-ec2-role"
  tags     = {}
  tags_all = {}
}

# __generated__ by Terraform from "three-tier-ec2-role:ReadRequiredAppSecret"
resource "aws_iam_role_policy" "secret" {
  name = "ReadRequiredAppSecret"
  policy = jsonencode({
    Statement = [{
      Action   = "secretsmanager:GetSecretValue"
      Effect   = "Allow"
      Resource = "arn:aws:secretsmanager:ap-southeast-2:802823597623:secret:rds!db-2907a3a1-63d5-4a1d-aabd-6eec73d8fa38-HZslER"
    }]
    Version = "2012-10-17"
  })
  role = "three-tier-ec2-role"
}

# __generated__ by Terraform
resource "aws_launch_template" "app" {
  description                          = "Initial Flask PostgreSQL application"
  disable_api_stop                     = false
  disable_api_termination              = false
  ebs_optimized                        = null
  image_id                             = "ami-0720cb7af233b0529"
  instance_initiated_shutdown_behavior = null
  instance_type                        = "t3.micro"
  kernel_id                            = null
  key_name                             = null
  name                                 = "three-tier-app-template"
  ram_disk_id                          = null
  region                               = "ap-southeast-2"
  tags                                 = {}
  tags_all                             = {}
  update_default_version               = true
  user_data                            = filebase64("${path.module}/user-data.sh")
  block_device_mappings {
    device_name  = "/dev/xvda"
    no_device    = null
    virtual_name = null
    ebs {
      delete_on_termination = "true"
      encrypted             = "true"
      iops                  = 3000
      kms_key_id            = null
      snapshot_id           = "snap-0d7c9920b3113e8f7"
      throughput            = 125
      volume_size           = 8
      volume_type           = "gp3"
    }
  }
  iam_instance_profile {
    arn  = "arn:aws:iam::802823597623:instance-profile/three-tier-ec2-role"
    name = null
  }
  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 2
    http_tokens                 = "required"
  }
  network_interfaces {
    associate_carrier_ip_address = null
    associate_public_ip_address  = "false"
    delete_on_termination        = "true"
    description                  = null
    device_index                 = 0
    ena_queue_count              = 0
    interface_type               = null
    ipv4_address_count           = 0
    ipv4_addresses               = []
    ipv4_prefix_count            = 0
    ipv4_prefixes                = []
    ipv6_address_count           = 0
    ipv6_addresses               = []
    ipv6_prefix_count            = 0
    ipv6_prefixes                = []
    network_card_index           = 0
    network_interface_id         = null
    primary_ipv6                 = null
    private_ip_address           = null
    security_groups              = ["sg-0f8f798e682cff882"]
    subnet_id                    = null
  }
}

# __generated__ by Terraform
resource "aws_cloudwatch_metric_alarm" "healthy" {
  actions_enabled     = true
  alarm_actions       = ["arn:aws:sns:ap-southeast-2:802823597623:three-tier-alerts"]
  alarm_description   = null
  alarm_name          = "three-tier-healthy-targets-low"
  comparison_operator = "LessThanThreshold"
  datapoints_to_alarm = 2
  dimensions = {
    LoadBalancer = "app/three-tier-alb/a1f633fb73f96546"
    TargetGroup  = "targetgroup/three-tier-app-tg/e60ce1a3f27cf320"
  }
  evaluation_periods        = 2
  extended_statistic        = null
  insufficient_data_actions = []
  metric_name               = "HealthyHostCount"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = []
  period                    = 60
  region                    = "ap-southeast-2"
  statistic                 = "Minimum"
  tags                      = {}
  tags_all                  = {}
  threshold                 = 2
  threshold_metric_id       = null
  treat_missing_data        = "breaching"
  unit                      = null
}

# __generated__ by Terraform
resource "aws_db_instance" "app" {
  lifecycle {
    ignore_changes = [apply_immediately, manage_master_user_password]
  }
  allocated_storage                     = 20
  allow_major_version_upgrade           = null
  apply_immediately                     = null
  auto_minor_version_upgrade            = true
  availability_zone                     = "ap-southeast-2b"
  backup_retention_period               = 1
  backup_target                         = "region"
  backup_window                         = "15:43-16:13"
  ca_cert_identifier                    = "rds-ca-rsa2048-g1"
  copy_tags_to_snapshot                 = true
  custom_iam_instance_profile           = null
  customer_owned_ip_enabled             = false
  database_insights_mode                = "standard"
  db_subnet_group_name                  = "three-tier-db-subnet-group"
  dedicated_log_volume                  = false
  delete_automated_backups              = true
  deletion_protection                   = false
  domain                                = null
  domain_auth_secret_arn                = null
  domain_iam_role_name                  = null
  domain_ou                             = null
  enabled_cloudwatch_logs_exports       = []
  engine                                = "postgres"
  engine_lifecycle_support              = "open-source-rds-extended-support-disabled"
  engine_version                        = "18.3"
  final_snapshot_identifier             = null
  iam_database_authentication_enabled   = false
  identifier                            = "database-1"
  instance_class                        = "db.t4g.micro"
  iops                                  = 0
  kms_key_id                            = "arn:aws:kms:ap-southeast-2:802823597623:key/9e186c22-90ca-4b78-a9ee-79ebe76b2977"
  license_model                         = "postgresql-license"
  maintenance_window                    = "fri:12:57-fri:13:27"
  manage_master_user_password           = true
  max_allocated_storage                 = 1000
  monitoring_interval                   = 0
  multi_az                              = false
  network_type                          = "IPV4"
  option_group_name                     = "default:postgres-18"
  parameter_group_name                  = "default.postgres18"
  password                              = null # sensitive
  password_wo                           = null # sensitive
  password_wo_version                   = null
  performance_insights_enabled          = true
  performance_insights_kms_key_id       = "arn:aws:kms:ap-southeast-2:802823597623:key/9e186c22-90ca-4b78-a9ee-79ebe76b2977"
  performance_insights_retention_period = 7
  port                                  = 5432
  publicly_accessible                   = false
  region                                = "ap-southeast-2"
  replicate_source_db                   = null
  skip_final_snapshot                   = true
  storage_encrypted                     = true
  storage_throughput                    = 0
  storage_type                          = "gp2"
  tags                                  = {}
  tags_all                              = {}
  upgrade_storage_config                = null
  username                              = "postgres"
  vpc_security_group_ids                = ["sg-0af5d8de4b493ce35"]
  warning_event_categories              = null
}

# __generated__ by Terraform from "three-tier-ec2-role/arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
resource "aws_iam_role_policy_attachment" "logs" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = "three-tier-ec2-role"
}

# __generated__ by Terraform
resource "aws_autoscaling_group" "app" {
  lifecycle {
    ignore_changes = [force_delete, force_delete_warm_pool, ignore_failed_scaling_activities, wait_for_capacity_timeout]
  }
  capacity_rebalance               = false
  context                          = null
  default_cooldown                 = 300
  default_instance_warmup          = 0
  desired_capacity                 = 2
  desired_capacity_type            = null
  enabled_metrics                  = []
  force_delete                     = null
  force_delete_warm_pool           = null
  health_check_grace_period        = 600
  health_check_type                = "ELB"
  ignore_failed_scaling_activities = null
  launch_configuration             = null
  load_balancers                   = []
  max_instance_lifetime            = 0
  max_size                         = 4
  metrics_granularity              = "1Minute"
  min_elb_capacity                 = null
  min_size                         = 2
  name                             = "three-tier-app-asg"
  placement_group                  = null
  protect_from_scale_in            = false
  region                           = "ap-southeast-2"
  service_linked_role_arn          = "arn:aws:iam::802823597623:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
  suspended_processes              = []
  target_group_arns                = ["arn:aws:elasticloadbalancing:ap-southeast-2:802823597623:targetgroup/three-tier-app-tg/e60ce1a3f27cf320"]
  termination_policies             = []
  vpc_zone_identifier              = ["subnet-00648a7f856cdd975", "subnet-027288d48813905c4"]
  wait_for_capacity_timeout        = null
  wait_for_elb_capacity            = null
  availability_zone_distribution {
    capacity_distribution_strategy = "balanced-best-effort"
  }
  capacity_reservation_specification {
    capacity_reservation_preference = "default"
  }
  instance_lifecycle_policy {
    retention_triggers {
      terminate_hook_abandon = "terminate"
    }
  }
  launch_template {
    id      = "lt-066a25789b97f1cce"
    version = aws_launch_template.app.latest_version
  }
  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "three-tier-asg-app"
  }
}

# __generated__ by Terraform from "three-tier-ec2-role"
resource "aws_iam_role" "ec2" {
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
  description           = null
  force_detach_policies = false
  max_session_duration  = 3600
  name                  = "three-tier-ec2-role"
  path                  = "/"
  permissions_boundary  = null
  tags                  = {}
  tags_all              = {}
}

# __generated__ by Terraform from "/three-tier/nginx/access"
resource "aws_cloudwatch_log_group" "access" {
  deletion_protection_enabled = false
  kms_key_id                  = null
  log_group_class             = "STANDARD"
  name                        = "/three-tier/nginx/access"
  region                      = "ap-southeast-2"
  retention_in_days           = 0
  skip_destroy                = false
  tags                        = {}
  tags_all                    = {}
}

# __generated__ by Terraform from "/three-tier/nginx/error"
resource "aws_cloudwatch_log_group" "error" {
  deletion_protection_enabled = false
  kms_key_id                  = null
  log_group_class             = "STANDARD"
  name                        = "/three-tier/nginx/error"
  region                      = "ap-southeast-2"
  retention_in_days           = 0
  skip_destroy                = false
  tags                        = {}
  tags_all                    = {}
}

# __generated__ by Terraform from "three-tier-db-subnet-group"
resource "aws_db_subnet_group" "app" {
  description = "Private database subnets across two Availability Zones"
  name        = "three-tier-db-subnet-group"
  region      = "ap-southeast-2"
  subnet_ids  = ["subnet-04771740eedc6faa7", "subnet-0a76be83c7ee6fde2"]
  tags        = {}
  tags_all    = {}
}

# __generated__ by Terraform from "802823597623:three-tier-spending-alert"
resource "aws_budgets_budget" "spending" {
  account_id        = "802823597623"
  billing_view_arn  = null
  budget_type       = "COST"
  limit_amount      = "10.0"
  limit_unit        = "USD"
  metrics           = ["UnblendedCost"]
  name              = "three-tier-spending-alert"
  tags              = {}
  tags_all          = {}
  time_period_end   = "2087-06-15_00:00"
  time_period_start = "2026-10-01_00:00"
  time_unit         = "MONTHLY"
  filter_expression {
    not {
      dimensions {
        key           = "RECORD_TYPE"
        match_options = []
        values        = ["Credit", "Refund"]
      }
    }
  }
  notification {
    comparison_operator        = "GREATER_THAN"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = ["ravishan.dileesha@gmail.com"]
    subscriber_sns_topic_arns  = []
    threshold                  = 1
    threshold_type             = "ABSOLUTE_VALUE"
  }
  notification {
    comparison_operator        = "GREATER_THAN"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = ["ravishan.dileesha@gmail.com"]
    subscriber_sns_topic_arns  = []
    threshold                  = 5
    threshold_type             = "ABSOLUTE_VALUE"
  }
  notification {
    comparison_operator        = "GREATER_THAN"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = ["ravishan.dileesha@gmail.com"]
    subscriber_sns_topic_arns  = []
    threshold                  = 10
    threshold_type             = "ABSOLUTE_VALUE"
  }
}

# __generated__ by Terraform
resource "aws_sns_topic" "alerts" {
  application_failure_feedback_role_arn    = null
  application_success_feedback_role_arn    = null
  application_success_feedback_sample_rate = 0
  archive_policy                           = null
  content_based_deduplication              = false
  delivery_policy                          = null
  display_name                             = null
  fifo_topic                               = false
  firehose_failure_feedback_role_arn       = null
  firehose_success_feedback_role_arn       = null
  firehose_success_feedback_sample_rate    = 0
  http_failure_feedback_role_arn           = null
  http_success_feedback_role_arn           = null
  http_success_feedback_sample_rate        = 0
  kms_master_key_id                        = null
  lambda_failure_feedback_role_arn         = null
  lambda_success_feedback_role_arn         = null
  lambda_success_feedback_sample_rate      = 0
  name                                     = "three-tier-alerts"
  policy = jsonencode({
    Id = "__default_policy_ID"
    Statement = [{
      Action = ["SNS:GetTopicAttributes", "SNS:SetTopicAttributes", "SNS:AddPermission", "SNS:RemovePermission", "SNS:DeleteTopic", "SNS:Subscribe", "SNS:ListSubscriptionsByTopic", "SNS:Publish"]
      Condition = {
        StringEquals = {
          "AWS:SourceOwner" = "802823597623"
        }
      }
      Effect = "Allow"
      Principal = {
        AWS = "*"
      }
      Resource = "arn:aws:sns:ap-southeast-2:802823597623:three-tier-alerts"
      Sid      = "__default_statement_ID"
    }]
    Version = "2008-10-17"
  })
  region                           = "ap-southeast-2"
  sqs_failure_feedback_role_arn    = null
  sqs_success_feedback_role_arn    = null
  sqs_success_feedback_sample_rate = 0
  tags                             = {}
  tags_all                         = {}
}



