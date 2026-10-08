# __generated__ by Terraform
# Please review these resources and move them into your main configuration files.

# __generated__ by Terraform from "subnet-00648a7f856cdd975/rtb-019ae99cbc660ab0b"
resource "aws_route_table_association" "app_b" {
  gateway_id     = null
  region         = "ap-southeast-2"
  route_table_id = "rtb-019ae99cbc660ab0b"
  subnet_id      = "subnet-00648a7f856cdd975"
}

# __generated__ by Terraform from "subnet-0a76be83c7ee6fde2/rtb-0e19598cc412008a4"
resource "aws_route_table_association" "db_b" {
  gateway_id     = null
  region         = "ap-southeast-2"
  route_table_id = "rtb-0e19598cc412008a4"
  subnet_id      = "subnet-0a76be83c7ee6fde2"
}

# __generated__ by Terraform from "subnet-006c896d9a08544b8/rtb-0fb886ceab3b35115"
resource "aws_route_table_association" "public_b" {
  gateway_id     = null
  region         = "ap-southeast-2"
  route_table_id = "rtb-0fb886ceab3b35115"
  subnet_id      = "subnet-006c896d9a08544b8"
}

# __generated__ by Terraform from "subnet-0a7f1b9127d89815f/rtb-0fb886ceab3b35115"
resource "aws_route_table_association" "public_a" {
  gateway_id     = null
  region         = "ap-southeast-2"
  route_table_id = "rtb-0fb886ceab3b35115"
  subnet_id      = "subnet-0a7f1b9127d89815f"
}

# __generated__ by Terraform from "subnet-04771740eedc6faa7/rtb-0e19598cc412008a4"
resource "aws_route_table_association" "db_a" {
  gateway_id     = null
  region         = "ap-southeast-2"
  route_table_id = "rtb-0e19598cc412008a4"
  subnet_id      = "subnet-04771740eedc6faa7"
}

# __generated__ by Terraform from "subnet-027288d48813905c4/rtb-0660fc06c87509b29"
resource "aws_route_table_association" "app_a" {
  gateway_id     = null
  region         = "ap-southeast-2"
  route_table_id = "rtb-0660fc06c87509b29"
  subnet_id      = "subnet-027288d48813905c4"
}
