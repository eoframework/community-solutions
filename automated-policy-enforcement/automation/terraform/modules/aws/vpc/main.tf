#------------------------------------------------------------------------------
# Tier 1: AWS VPC — Network Account inspection VPC
# Hub-and-spoke with Network Firewall, NAT Gateway, and VPC Endpoints
#------------------------------------------------------------------------------

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  az_count = min(2, length(data.aws_availability_zones.available.names))

  # Derive subnet CIDRs from VPC CIDR
  vpc_prefix = regex("^(\\d+\\.\\d+)\\.\\d+\\.\\d+/\\d+$", var.vpc_cidr)[0]

  public_subnets  = [for i in range(local.az_count) : "${local.vpc_prefix}.${i + 0}.0/28"]
  private_subnets = [for i in range(local.az_count) : "${local.vpc_prefix}.${i + 16}.0/24"]
  tgw_subnets     = [for i in range(local.az_count) : "${local.vpc_prefix}.${i + 48}.0/28"]
  fw_subnets      = [for i in range(local.az_count) : "${local.vpc_prefix}.${i + 64}.0/28"]
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-vpc"
  })
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-igw"
  })
}

resource "aws_subnet" "public" {
  count             = local.az_count
  vpc_id            = aws_vpc.main.id
  cidr_block        = local.public_subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-public-${count.index + 1}"
    Tier = "public"
  })
}

resource "aws_subnet" "private" {
  count             = local.az_count
  vpc_id            = aws_vpc.main.id
  cidr_block        = local.private_subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-private-${count.index + 1}"
    Tier = "private"
  })
}

resource "aws_subnet" "tgw" {
  count             = local.az_count
  vpc_id            = aws_vpc.main.id
  cidr_block        = local.tgw_subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-tgw-${count.index + 1}"
    Tier = "transit-gateway"
  })
}

resource "aws_subnet" "firewall" {
  count             = var.firewall_inspection_enabled ? local.az_count : 0
  vpc_id            = aws_vpc.main.id
  cidr_block        = local.fw_subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-fw-${count.index + 1}"
    Tier = "firewall"
  })
}

resource "aws_eip" "nat" {
  count  = var.nat_gateway_count
  domain = "vpc"
  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-nat-eip-${count.index + 1}"
  })
}

resource "aws_nat_gateway" "main" {
  count         = var.nat_gateway_count
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index % local.az_count].id
  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-nat-${count.index + 1}"
  })
  depends_on = [aws_internet_gateway.main]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-rt-public"
  })
}

resource "aws_route" "public_igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  count          = local.az_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  count  = local.az_count
  vpc_id = aws_vpc.main.id
  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-rt-private-${count.index + 1}"
  })
}

resource "aws_route" "private_nat" {
  count                  = local.az_count
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[min(count.index, var.nat_gateway_count - 1)].id
}

resource "aws_route_table_association" "private" {
  count          = local.az_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

#------------------------------------------------------------------------------
# VPC Endpoints — keep service API calls on AWS private network
#------------------------------------------------------------------------------
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = aws_route_table.private[*].id
  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-vpce-s3"
  })
}

data "aws_region" "current" {}
