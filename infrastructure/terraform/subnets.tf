# __generated__ by Terraform
# Please review these resources and move them into your main configuration files.

# __generated__ by Terraform
resource "aws_subnet" "db_b" {
  assign_ipv6_address_on_creation                = false
  availability_zone                              = "ap-southeast-2b"
  cidr_block                                     = "10.0.22.0/24"
  customer_owned_ipv4_pool                       = null
  enable_dns64                                   = false
  enable_resource_name_dns_a_record_on_launch    = false
  enable_resource_name_dns_aaaa_record_on_launch = false
  ipv4_ipam_pool_id                              = null
  ipv4_netmask_length                            = null
  ipv6_ipam_pool_id                              = null
  ipv6_native                                    = false
  ipv6_netmask_length                            = null
  map_public_ip_on_launch                        = false
  outpost_arn                                    = null
  private_dns_hostname_type_on_launch            = "ip-name"
  region                                         = "ap-southeast-2"
  tags = {
    Name = "db-b"
  }
  tags_all = {
    Name = "db-b"
  }
  vpc_id = "vpc-0a8dbf239a41dbd51"
}

# __generated__ by Terraform
resource "aws_subnet" "public_b" {
  assign_ipv6_address_on_creation                = false
  availability_zone                              = "ap-southeast-2b"
  cidr_block                                     = "10.0.2.0/24"
  customer_owned_ipv4_pool                       = null
  enable_dns64                                   = false
  enable_resource_name_dns_a_record_on_launch    = false
  enable_resource_name_dns_aaaa_record_on_launch = false
  ipv4_ipam_pool_id                              = null
  ipv4_netmask_length                            = null
  ipv6_ipam_pool_id                              = null
  ipv6_native                                    = false
  ipv6_netmask_length                            = null
  map_public_ip_on_launch                        = false
  outpost_arn                                    = null
  private_dns_hostname_type_on_launch            = "ip-name"
  region                                         = "ap-southeast-2"
  tags = {
    Name = "public-b"
  }
  tags_all = {
    Name = "public-b"
  }
  vpc_id = "vpc-0a8dbf239a41dbd51"
}

# __generated__ by Terraform
resource "aws_subnet" "db_a" {
  assign_ipv6_address_on_creation = false
  availability_zone               = "ap-southeast-2a"

  cidr_block                                     = "10.0.21.0/24"
  customer_owned_ipv4_pool                       = null
  enable_dns64                                   = false
  enable_resource_name_dns_a_record_on_launch    = false
  enable_resource_name_dns_aaaa_record_on_launch = false
  ipv4_ipam_pool_id                              = null
  ipv4_netmask_length                            = null
  ipv6_ipam_pool_id                              = null
  ipv6_native                                    = false
  ipv6_netmask_length                            = null
  map_public_ip_on_launch                        = false
  outpost_arn                                    = null
  private_dns_hostname_type_on_launch            = "ip-name"
  region                                         = "ap-southeast-2"
  tags = {
    Name = "db-a"
  }
  tags_all = {
    Name = "db-a"
  }
  vpc_id = "vpc-0a8dbf239a41dbd51"
}

# __generated__ by Terraform
resource "aws_subnet" "app_b" {
  assign_ipv6_address_on_creation                = false
  availability_zone                              = "ap-southeast-2b"
  cidr_block                                     = "10.0.12.0/24"
  customer_owned_ipv4_pool                       = null
  enable_dns64                                   = false
  enable_resource_name_dns_a_record_on_launch    = false
  enable_resource_name_dns_aaaa_record_on_launch = false
  ipv4_ipam_pool_id                              = null
  ipv4_netmask_length                            = null
  ipv6_ipam_pool_id                              = null
  ipv6_native                                    = false
  ipv6_netmask_length                            = null
  map_public_ip_on_launch                        = false
  outpost_arn                                    = null
  private_dns_hostname_type_on_launch            = "ip-name"
  region                                         = "ap-southeast-2"
  tags = {
    Name = "app-b"
  }
  tags_all = {
    Name = "app-b"
  }
  vpc_id = "vpc-0a8dbf239a41dbd51"
}

# __generated__ by Terraform
resource "aws_subnet" "app_a" {
  assign_ipv6_address_on_creation = false
  availability_zone               = "ap-southeast-2a"

  cidr_block                                     = "10.0.11.0/24"
  customer_owned_ipv4_pool                       = null
  enable_dns64                                   = false
  enable_resource_name_dns_a_record_on_launch    = false
  enable_resource_name_dns_aaaa_record_on_launch = false
  ipv4_ipam_pool_id                              = null
  ipv4_netmask_length                            = null
  ipv6_ipam_pool_id                              = null
  ipv6_native                                    = false
  ipv6_netmask_length                            = null
  map_public_ip_on_launch                        = false
  outpost_arn                                    = null
  private_dns_hostname_type_on_launch            = "ip-name"
  region                                         = "ap-southeast-2"
  tags = {
    Name = "app-a"
  }
  tags_all = {
    Name = "app-a"
  }
  vpc_id = "vpc-0a8dbf239a41dbd51"
}

# __generated__ by Terraform
resource "aws_subnet" "public_a" {
  assign_ipv6_address_on_creation = false
  availability_zone               = "ap-southeast-2a"

  cidr_block               = "10.0.1.0/24"
  customer_owned_ipv4_pool = null
  enable_dns64             = false

  enable_resource_name_dns_a_record_on_launch    = false
  enable_resource_name_dns_aaaa_record_on_launch = false
  ipv4_ipam_pool_id                              = null
  ipv4_netmask_length                            = null
  ipv6_ipam_pool_id                              = null
  ipv6_native                                    = false
  ipv6_netmask_length                            = null
  map_public_ip_on_launch                        = false
  outpost_arn                                    = null
  private_dns_hostname_type_on_launch            = "ip-name"
  region                                         = "ap-southeast-2"
  tags = {
    Name = "public-a"
  }
  tags_all = {
    Name = "public-a"
  }
  vpc_id = "vpc-0a8dbf239a41dbd51"
}

