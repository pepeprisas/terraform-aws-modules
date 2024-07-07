resource "aws_subnet" "public_subnet" {
  count                   = "${length(var.availability_zones)}"
  cidr_block              = "${var.vpc_cidr_prefix}.${var.vpc_cidr_block}.${var.vpc_cidr_3AZ_public[count.index]}"
  availability_zone       = "${var.availability_zones[count.index]}"
  vpc_id                  = "${var.vpc_id}"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.service}-public-${var.role}-${var.environment}-${var.availability_zones[count.index]}"
    Service = "${var.service}"
    Role = "${var.role}"
    Environment ="${var.environment}"
    Region ="${var.region}"
    Visibility = "public"
  }
}

resource "aws_subnet" "private_subnet" {
  count                   = "${length(var.availability_zones)}"
  cidr_block              = "${var.vpc_cidr_prefix}.${var.vpc_cidr_block}.${var.vpc_cidr_3AZ_private[count.index]}"
  availability_zone       = "${var.availability_zones[count.index]}"
  vpc_id                  = "${var.vpc_id}"
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.service}-private-${var.role}-${var.environment}-${var.availability_zones[count.index]}"
    Service = "${var.service}"
    Role = "${var.role}"
    Environment ="${var.environment}"
    Region ="${var.region}"
    Visibility = "private"
  }
}
