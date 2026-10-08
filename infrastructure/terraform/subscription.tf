# __generated__ by Terraform
# Please review these resources and move them into your main configuration files.

# __generated__ by Terraform from "arn:aws:sns:ap-southeast-2:802823597623:three-tier-alerts:b62c37c1-5c6c-4348-b09b-0a556db151a4"
resource "aws_sns_topic_subscription" "email" {
  lifecycle {
    ignore_changes = [confirmation_timeout_in_minutes, endpoint_auto_confirms]
  }
  confirmation_timeout_in_minutes = null
  delivery_policy                 = null
  endpoint                        = "ravishan.dileesha@gmail.com"
  endpoint_auto_confirms          = null
  filter_policy                   = null
  protocol                        = "email"
  raw_message_delivery            = false
  redrive_policy                  = null
  region                          = "ap-southeast-2"
  replay_policy                   = null
  subscription_role_arn           = null
  topic_arn                       = "arn:aws:sns:ap-southeast-2:802823597623:three-tier-alerts"
}

