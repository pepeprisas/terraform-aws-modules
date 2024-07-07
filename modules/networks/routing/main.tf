###################
# Internet Gateway
###################
resource "aws_internet_gateway" "igw" {
  vpc_id = "${var.vpc_id}"

  tags = {
    Name = "${var.service}-${var.role}-igw-${var.environment}"
    Service = "${var.service}"
    Role = "${var.role}-igw"
    Environment ="${var.environment}"
    Region ="${var.region}"
  }
}

###################
# NAT Gateway
###################
resource "aws_eip" "nat_gateway_ip" {
  vpc = true

  tags = {
    Name = "${var.service}-${var.role}-ngw-${var.environment}"
    Service = "${var.service}"
    Role = "${var.role}-ngw"
    Environment ="${var.environment}"
    Region ="${var.region}"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = "${aws_eip.nat_gateway_ip.id}"
  subnet_id     = "${element(var.public_subnet_ids, 0)}"

  tags = {
    Name = "${var.service}-${var.role}-ngw-${var.environment}"
    Service = "${var.service}"
    Role = "${var.role}-ngw"
    Environment ="${var.environment}"
    Region ="${var.region}"
  }

  depends_on = ["aws_internet_gateway.igw"]
}


################
# Publiс routes
################
resource "aws_route_table" "public_route_table" {
  vpc_id = "${var.vpc_id}"

  tags = {
    Name = "${var.service}-${var.role}-public-route-table-${var.environment}"
    Service = "${var.service}"
    Role = "${var.role}-public-route-table"
    Environment ="${var.environment}"
    Region ="${var.region}"
  }
}

resource "aws_route" "public_route" {
  route_table_id         = "${aws_route_table.public_route_table.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.igw.id}"

  timeouts {
    create = "5m"
  }

  depends_on                = ["aws_route_table.public_route_table"]
}

################
# Private routes
################

resource "aws_route_table" "private_route_table" {
  count = "${var.items}"
  vpc_id = "${var.vpc_id}"

  lifecycle {
    # When attaching VPN gateways it is common to define aws_vpn_gateway_route_propagation
    # resources that manipulate the attributes of the routing table (typically for the private subnets)
    ignore_changes = ["propagating_vgws"]
  }

  tags = {
    Name = "${var.service}-${var.role}-private-route-table-${var.environment}-${count.index}"
    Service = "${var.service}"
    Role = "${var.role}-private-route-table"
    Environment ="${var.environment}"
    Region ="${var.region}"
  }
}

resource "aws_route" "private_route" {
  count = "${var.items}"

  route_table_id         = "${element(aws_route_table.private_route_table.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.nat_gw.id}"

  timeouts {
    create = "5m"
  }

  depends_on                = ["aws_route_table.private_route_table"]
}

##########################
# Route table associations
##########################

resource "aws_route_table_association" "private" {
  count = "${var.items}"

  subnet_id      = "${var.private_subnet_ids[count.index]}"
  route_table_id = "${element(aws_route_table.private_route_table.*.id, count.index)}"
}


resource "aws_route_table_association" "public" {
  count = "${var.items}"

  subnet_id      = "${var.public_subnet_ids[count.index]}"
  route_table_id = "${element(aws_route_table.public_route_table.*.id, count.index)}"
}
