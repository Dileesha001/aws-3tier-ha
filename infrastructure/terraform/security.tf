# __generated__ by Terraform
# Please review these resources and move them into your main configuration files.

# __generated__ by Terraform from "sg-0f8f798e682cff882"
resource "aws_security_group" "app" {
  description = "Application access from load balancer"
  egress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = ""
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "-1"
    security_groups  = []
    self             = false
    to_port          = 0
  }]
  ingress = [{
    cidr_blocks      = []
    description      = ""
    from_port        = 80
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = ["sg-069b9e14dd9515882"]
    self             = false
    to_port          = 80
  }]
  name                   = "three-tier-app"
  region                 = "ap-southeast-2"
  revoke_rules_on_delete = null
  tags = {
    Name = "sg-app"
  }
  tags_all = {
    Name = "sg-app"
  }
  vpc_id = "vpc-0a8dbf239a41dbd51"
}

# __generated__ by Terraform from "sg-069b9e14dd9515882"
resource "aws_security_group" "alb" {
  description = "HTTP access to application load balancer"
  egress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = ""
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "-1"
    security_groups  = []
    self             = false
    to_port          = 0
  }]
  ingress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = ""
    from_port        = 443
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = []
    self             = false
    to_port          = 443
    }, {
    cidr_blocks      = ["0.0.0.0/0"]
    description      = ""
    from_port        = 80
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = []
    self             = false
    to_port          = 80
  }]
  name                   = "three-tier-alb"
  region                 = "ap-southeast-2"
  revoke_rules_on_delete = null
  tags = {
    Name = "sg-alb"
  }
  tags_all = {
    Name = "sg-alb"
  }
  vpc_id = "vpc-0a8dbf239a41dbd51"
}

# __generated__ by Terraform from "sg-0af5d8de4b493ce35"
resource "aws_security_group" "db" {
  description = "Database access from application tier"
  egress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = ""
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "-1"
    security_groups  = []
    self             = false
    to_port          = 0
  }]
  ingress = [{
    cidr_blocks      = []
    description      = ""
    from_port        = 5432
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = ["sg-0f8f798e682cff882"]
    self             = false
    to_port          = 5432
  }]
  name                   = "three-tier-db"
  region                 = "ap-southeast-2"
  revoke_rules_on_delete = null
  tags = {
    Name = "sg-db"
  }
  tags_all = {
    Name = "sg-db"
  }
  vpc_id = "vpc-0a8dbf239a41dbd51"
}
