import {
  to = aws_vpc.three_tier
  id = "vpc-0a8dbf239a41dbd51"
}

import {
  to = aws_subnet.public_a
  id = "subnet-0a7f1b9127d89815f"
}

import {
  to = aws_subnet.public_b
  id = "subnet-006c896d9a08544b8"
}

import {
  to = aws_subnet.app_a
  id = "subnet-027288d48813905c4"
}

import {
  to = aws_subnet.app_b
  id = "subnet-00648a7f856cdd975"
}

import {
  to = aws_subnet.db_a
  id = "subnet-04771740eedc6faa7"
}

import {
  to = aws_subnet.db_b
  id = "subnet-0a76be83c7ee6fde2"
}

import {
  to = aws_internet_gateway.three_tier
  id = "igw-01694b9a9a9d9e0e2"
}

import {
  to = aws_eip.nat_a
  id = "eipalloc-0fdeb985932c38ee1"
}

import {
  to = aws_eip.nat_b
  id = "eipalloc-03b5ab5c295fbae17"
}

import {
  to = aws_nat_gateway.nat_a
  id = "nat-08f03c5587ddf9fd6"
}

import {
  to = aws_nat_gateway.nat_b
  id = "nat-00dc945d24f80d488"
}
import {
  to = aws_route_table.public
  id = "rtb-0fb886ceab3b35115"
}

import {
  to = aws_route_table.app_a
  id = "rtb-0660fc06c87509b29"
}

import {
  to = aws_route_table.app_b
  id = "rtb-019ae99cbc660ab0b"
}

import {
  to = aws_route_table.db
  id = "rtb-0e19598cc412008a4"
}
import {
  to = aws_route_table_association.public_a
  id = "subnet-0a7f1b9127d89815f/rtb-0fb886ceab3b35115"
}

import {
  to = aws_route_table_association.public_b
  id = "subnet-006c896d9a08544b8/rtb-0fb886ceab3b35115"
}

import {
  to = aws_route_table_association.app_a
  id = "subnet-027288d48813905c4/rtb-0660fc06c87509b29"
}

import {
  to = aws_route_table_association.app_b
  id = "subnet-00648a7f856cdd975/rtb-019ae99cbc660ab0b"
}

import {
  to = aws_route_table_association.db_a
  id = "subnet-04771740eedc6faa7/rtb-0e19598cc412008a4"
}

import {
  to = aws_route_table_association.db_b
  id = "subnet-0a76be83c7ee6fde2/rtb-0e19598cc412008a4"
}
import {
  to = aws_security_group.alb
  id = "sg-069b9e14dd9515882"
}

import {
  to = aws_security_group.app
  id = "sg-0f8f798e682cff882"
}

import {
  to = aws_security_group.db
  id = "sg-0af5d8de4b493ce35"
}
import {
  to = aws_lb.app
  id = "arn:aws:elasticloadbalancing:ap-southeast-2:802823597623:loadbalancer/app/three-tier-alb/a1f633fb73f96546"
}

import {
  to = aws_lb_listener.http
  id = "arn:aws:elasticloadbalancing:ap-southeast-2:802823597623:listener/app/three-tier-alb/a1f633fb73f96546/78c703f6317830af"
}

import {
  to = aws_lb_target_group.app
  id = "arn:aws:elasticloadbalancing:ap-southeast-2:802823597623:targetgroup/three-tier-app-tg/e60ce1a3f27cf320"
}
