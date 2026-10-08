# __generated__ by Terraform
# Please review these resources and move them into your main configuration files.

# __generated__ by Terraform
resource "aws_route_table" "public" {
  propagating_vgws = []
  region           = "ap-southeast-2"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "igw-01694b9a9a9d9e0e2"
  }
  tags = {
    Name = "rt-public"
  }
  tags_all = {
    Name = "rt-public"
  }
  vpc_id = "vpc-0a8dbf239a41dbd51"
}

# __generated__ by Terraform
resource "aws_route_table" "app_a" {
  propagating_vgws = []
  region           = "ap-southeast-2"
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "nat-08f03c5587ddf9fd6"
  }
  tags = {
    Name = "rt-app-a"
  }
  tags_all = {
    Name = "rt-app-a"
  }
  vpc_id = "vpc-0a8dbf239a41dbd51"
}

# __generated__ by Terraform
resource "aws_route_table" "app_b" {
  propagating_vgws = []
  region           = "ap-southeast-2"
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "nat-08f03c5587ddf9fd6"
  }
  tags = {
    Name = "rt-app-b"
  }
  tags_all = {
    Name = "rt-app-b"
  }
  vpc_id = "vpc-0a8dbf239a41dbd51"
}

# __generated__ by Terraform from "rtb-0e19598cc412008a4"
resource "aws_route_table" "db" {
  propagating_vgws = []
  region           = "ap-southeast-2"
  route            = []
  tags = {
    Name = "rt-db"
  }
  tags_all = {
    Name = "rt-db"
  }
  vpc_id = "vpc-0a8dbf239a41dbd51"
}

