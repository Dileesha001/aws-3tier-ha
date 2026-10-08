# __generated__ by Terraform
# Please review these resources and move them into your main configuration files.

# __generated__ by Terraform
resource "aws_lb_target_group" "app" {
  deregistration_delay               = "300"
  ip_address_type                    = "ipv4"
  lambda_multi_value_headers_enabled = null
  load_balancing_algorithm_type      = "round_robin"
  load_balancing_anomaly_mitigation  = "off"
  load_balancing_cross_zone_enabled  = "use_load_balancer_configuration"
  name                               = "three-tier-app-tg"
  port                               = 80
  protocol                           = "HTTP"
  protocol_version                   = "HTTP1"
  proxy_protocol_v2                  = null
  region                             = "ap-southeast-2"
  slow_start                         = 0
  tags                               = {}
  tags_all                           = {}
  target_type                        = "instance"
  vpc_id                             = "vpc-0a8dbf239a41dbd51"
  health_check {
    enabled             = true
    healthy_threshold   = 5
    interval            = 30
    matcher             = "200"
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }
  stickiness {
    cookie_duration = 86400
    cookie_name     = null
    enabled         = false
    type            = "lb_cookie"
  }
  target_group_health {
    dns_failover {
      minimum_healthy_targets_count      = "1"
      minimum_healthy_targets_percentage = "off"
    }
    unhealthy_state_routing {
      minimum_healthy_targets_count      = 1
      minimum_healthy_targets_percentage = "off"
    }
  }
}

# __generated__ by Terraform from "arn:aws:elasticloadbalancing:ap-southeast-2:802823597623:listener/app/three-tier-alb/a1f633fb73f96546/78c703f6317830af"
resource "aws_lb_listener" "http" {
  alpn_policy                          = null
  certificate_arn                      = null
  load_balancer_arn                    = "arn:aws:elasticloadbalancing:ap-southeast-2:802823597623:loadbalancer/app/three-tier-alb/a1f633fb73f96546"
  port                                 = 80
  protocol                             = "HTTP"
  region                               = "ap-southeast-2"
  routing_http_response_server_enabled = true
  tags                                 = {}
  tags_all                             = {}
  default_action {
    order            = 1
    target_group_arn = "arn:aws:elasticloadbalancing:ap-southeast-2:802823597623:targetgroup/three-tier-app-tg/e60ce1a3f27cf320"
    type             = "forward"
    forward {
      stickiness {
        duration = 3600
        enabled  = false
      }
      target_group {
        arn    = "arn:aws:elasticloadbalancing:ap-southeast-2:802823597623:targetgroup/three-tier-app-tg/e60ce1a3f27cf320"
        weight = 1
      }
    }
  }
}

# __generated__ by Terraform
resource "aws_lb" "app" {
  client_keep_alive                           = 3600
  customer_owned_ipv4_pool                    = null
  desync_mitigation_mode                      = "defensive"
  dns_record_client_routing_policy            = null
  drop_invalid_header_fields                  = false
  enable_cross_zone_load_balancing            = true
  enable_deletion_protection                  = false
  enable_http2                                = true
  enable_tls_version_and_cipher_suite_headers = false
  enable_waf_fail_open                        = false
  enable_xff_client_port                      = false
  enable_zonal_shift                          = false
  idle_timeout                                = 60
  internal                                    = false
  ip_address_type                             = "ipv4"
  load_balancer_type                          = "application"
  name                                        = "three-tier-alb"
  preserve_host_header                        = false
  region                                      = "ap-southeast-2"
  security_groups                             = ["sg-069b9e14dd9515882"]
  subnets                                     = ["subnet-006c896d9a08544b8", "subnet-0a7f1b9127d89815f"]
  tags                                        = {}
  tags_all                                    = {}
  xff_header_processing_mode                  = "append"
  access_logs {
    bucket  = ""
    enabled = false
    prefix  = null
  }
  connection_logs {
    bucket  = ""
    enabled = false
    prefix  = null
  }
  health_check_logs {
    bucket  = ""
    enabled = false
    prefix  = null
  }
}

