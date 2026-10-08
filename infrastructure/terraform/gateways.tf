# __generated__ by Terraform
# Please review these resources and move them into your main configuration files.

# __generated__ by Terraform
resource "aws_nat_gateway" "nat_b" {
  allocation_id            = "eipalloc-03b5ab5c295fbae17"
  availability_mode        = "zonal"
  connectivity_type        = "public"
  private_ip               = "10.0.2.157"
  region                   = "ap-southeast-2"
  secondary_allocation_ids = []
  subnet_id                = "subnet-006c896d9a08544b8"
  tags = {
    Name = "nat-b"
  }
  tags_all = {
    Name = "nat-b"
  }
  vpc_id = "vpc-0a8dbf239a41dbd51"
}

# __generated__ by Terraform from "igw-01694b9a9a9d9e0e2"
resource "aws_internet_gateway" "three_tier" {
  region = "ap-southeast-2"
  tags = {
    Name = "three-tier-igw"
  }
  tags_all = {
    Name = "three-tier-igw"
  }
  vpc_id = "vpc-0a8dbf239a41dbd51"
}

# __generated__ by Terraform
resource "aws_nat_gateway" "nat_a" {
  allocation_id            = "eipalloc-0fdeb985932c38ee1"
  availability_mode        = "zonal"
  connectivity_type        = "public"
  private_ip               = "10.0.1.60"
  region                   = "ap-southeast-2"
  secondary_allocation_ids = []
  subnet_id                = "subnet-0a7f1b9127d89815f"
  tags = {
    Name = "nat-a"
  }
  tags_all = {
    Name = "nat-a"
  }
  vpc_id = "vpc-0a8dbf239a41dbd51"
}

# __generated__ by Terraform from "eipalloc-03b5ab5c295fbae17"
resource "aws_eip" "nat_b" {
  address                   = null
  associate_with_private_ip = null
  customer_owned_ipv4_pool  = null
  domain                    = "vpc"
  network_border_group      = "ap-southeast-2"
  network_interface         = "eni-05338a40baf3ff361"
  public_ipv4_pool          = "amazon"
  region                    = "ap-southeast-2"
  tags                      = {}
  tags_all                  = {}
}

# __generated__ by Terraform from "eipalloc-0fdeb985932c38ee1"
resource "aws_eip" "nat_a" {
  address                   = null
  associate_with_private_ip = null
  customer_owned_ipv4_pool  = null
  domain                    = "vpc"
  network_border_group      = "ap-southeast-2"
  network_interface         = "eni-04009cfd64105fdf0"
  public_ipv4_pool          = "amazon"
  region                    = "ap-southeast-2"
  tags                      = {}
  tags_all                  = {}
}

