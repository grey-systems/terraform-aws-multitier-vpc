resource "aws_vpc" "pro" {
  cidr_block           = "${var.cidr_block}"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.environment}-vpc"
    Env  = "${var.environment}"
  }
}

resource "aws_subnet" "pm_pro_public" {
  vpc_id                  = "${aws_vpc.pro.id}"
  count                   = "${length(var.public_cidr_blocks)}"
  availability_zone       = "${element(var.availability_zones,count.index)}"
  cidr_block              = "${element(var.public_cidr_blocks,count.index)}"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.environment}-public-subnet-${count.index}"
    Env  = "${var.environment}"
  }
}

resource "aws_subnet" "pm_pro_private" {
  vpc_id            = "${aws_vpc.pro.id}"
  count             = "${length(var.private_cidr_blocks)}"
  availability_zone = "${element(var.availability_zones,count.index)}"
  cidr_block        = "${element(var.private_cidr_blocks,count.index)}"

  tags = {
    Name = "${var.environment}-private-subnet-${count.index}"
    Env  = "${var.environment}"
  }
}

resource "aws_eip" "nat_ip" {
  count = "${length(var.public_cidr_blocks)}"
  vpc   = true
}

resource "aws_internet_gateway" "internet_gw" {
  vpc_id = "${aws_vpc.pro.id}"

  tags = {
    Name = "${var.environment}-internet-gw"
    Env  = "${var.environment}"
  }
}

# Configuration of the vpn
resource "aws_customer_gateway" "customer_gateway" {
  bgp_asn    = 60000
  ip_address = "${var.customer_gateway_ip}"
  type       = "ipsec.1"

  tags = {
    Name = "${var.customer_gateway_name}-${var.environment}"
    Env  = "${var.environment}"
  }
}

resource "aws_vpn_gateway" "vpn_gw" {
  vpc_id = "${aws_vpc.pro.id}"

  tags = {
    Name = "${var.customer_gateway_name}-${var.environment}-vpn-gw"
    Env  = "${var.environment}"
  }
}

resource "aws_vpn_connection" "main" {
  vpn_gateway_id      = "${aws_vpn_gateway.vpn_gw.id}"
  customer_gateway_id = "${aws_customer_gateway.customer_gateway.id}"
  type                = "ipsec.1"
  static_routes_only  = true

  tags = {
    Name = "${var.customer_gateway_name}-${var.environment}"
    Env  = "${var.environment}"
  }
}

resource "aws_vpn_connection_route" "static_routes" {
  count                  = "${length(split(",", var.subnets_vpn))}"
  destination_cidr_block = "${element(split(",", var.subnets_vpn),count.index)}"
  vpn_connection_id      = "${aws_vpn_connection.main.id}"
}

##################################

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = "${element(aws_eip.nat_ip.*.id,count.index)}"
  count         = "${length(var.public_cidr_blocks)}"
  subnet_id     = "${element(aws_subnet.pm_pro_public.*.id,count.index)}"
  depends_on    = [aws_internet_gateway.internet_gw]
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.pro.id}"
  count  = "${length(var.private_cidr_blocks)}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${element(aws_nat_gateway.nat_gw.*.id, count.index)}"
  }

  propagating_vgws = ["${aws_vpn_gateway.vpn_gw.id}"]

  tags = {
    Name = "${var.environment}-private-route-table-${count.index}"
    Env  = "${var.environment}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.pro.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.internet_gw.id}"
  }

  propagating_vgws = ["${aws_vpn_gateway.vpn_gw.id}"]

  tags = {
    Name = "${var.environment}-public-route-table"
    Env  = "${var.environment}"
  }
}

resource "aws_route_table_association" "public" {
  count          = "${length(var.public_cidr_blocks)}"
  subnet_id      = "${element(aws_subnet.pm_pro_public.*.id,count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "private" {
  count          = "${length(var.private_cidr_blocks)}"
  subnet_id      = "${element(aws_subnet.pm_pro_private.*.id,count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}

output "public_subnets_ids" {
  value = "${join(",", aws_subnet.pm_pro_public.*.id)}"
}

output "private_subnets_ids" {
  value = "${join(",", aws_subnet.pm_pro_private.*.id)}"
}

output "vpc_id" {
  value = "${aws_vpc.pro.id}"
}

output "vpn_gw_id" {
  value = "${aws_vpn_gateway.vpn_gw.id}"
}

output "default_vpc_secgroup_id" {
  value = "${aws_vpc.pro.default_security_group_id}"
}

output "nat_public_ips" {
  value = ["${aws_eip.nat_ip.*.public_ip}"]
}
