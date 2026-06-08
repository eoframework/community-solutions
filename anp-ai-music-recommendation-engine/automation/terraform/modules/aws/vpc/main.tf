#------------------------------------------------------------------------------
# Tier 1 — AWS VPC: VPC, Subnets, Internet Gateway, NAT Gateways,
# Route Tables, and VPC Gateway Endpoints (S3 + DynamoDB)
#------------------------------------------------------------------------------

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-vpc"
  })
}

#-- Internet Gateway -----------------------------------------------------------
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-igw"
  })
}

#-- Public Subnets ------------------------------------------------------------
resource "aws_subnet" "public_az1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_az1
  availability_zone       = "${data.aws_region.current.name}a"
  map_public_ip_on_launch = false

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-public-az1"
    Tier = "public"
  })
}

resource "aws_subnet" "public_az2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_az2
  availability_zone       = "${data.aws_region.current.name}b"
  map_public_ip_on_launch = false

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-public-az2"
    Tier = "public"
  })
}

#-- Private Application Subnets -----------------------------------------------
resource "aws_subnet" "private_app_az1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_app_az1
  availability_zone = "${data.aws_region.current.name}a"

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-private-app-az1"
    Tier = "private-app"
  })
}

resource "aws_subnet" "private_app_az2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_app_az2
  availability_zone = "${data.aws_region.current.name}b"

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-private-app-az2"
    Tier = "private-app"
  })
}

#-- Private Data Subnets -------------------------------------------------------
resource "aws_subnet" "private_data_az1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_data_az1
  availability_zone = "${data.aws_region.current.name}a"

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-private-data-az1"
    Tier = "private-data"
  })
}

resource "aws_subnet" "private_data_az2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_data_az2
  availability_zone = "${data.aws_region.current.name}b"

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-private-data-az2"
    Tier = "private-data"
  })
}

#-- Elastic IPs for NAT Gateways ----------------------------------------------
resource "aws_eip" "nat" {
  count  = var.nat_gateway_count
  domain = "vpc"

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-nat-eip-${count.index + 1}"
  })

  depends_on = [aws_internet_gateway.main]
}

#-- NAT Gateways --------------------------------------------------------------
resource "aws_nat_gateway" "main" {
  count         = var.nat_gateway_count
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = count.index == 0 ? aws_subnet.public_az1.id : aws_subnet.public_az2.id

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-nat-gw-${count.index + 1}"
  })

  depends_on = [aws_internet_gateway.main]
}

#-- Public Route Table --------------------------------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-rt-public"
  })
}

resource "aws_route_table_association" "public_az1" {
  subnet_id      = aws_subnet.public_az1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_az2" {
  subnet_id      = aws_subnet.public_az2.id
  route_table_id = aws_route_table.public.id
}

#-- Private Route Tables ------------------------------------------------------
resource "aws_route_table" "private_az1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[0].id
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-rt-private-az1"
  })
}

resource "aws_route_table" "private_az2" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[var.nat_gateway_count > 1 ? 1 : 0].id
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-rt-private-az2"
  })
}

resource "aws_route_table_association" "private_app_az1" {
  subnet_id      = aws_subnet.private_app_az1.id
  route_table_id = aws_route_table.private_az1.id
}

resource "aws_route_table_association" "private_app_az2" {
  subnet_id      = aws_subnet.private_app_az2.id
  route_table_id = aws_route_table.private_az2.id
}

resource "aws_route_table_association" "private_data_az1" {
  subnet_id      = aws_subnet.private_data_az1.id
  route_table_id = aws_route_table.private_az1.id
}

resource "aws_route_table_association" "private_data_az2" {
  subnet_id      = aws_subnet.private_data_az2.id
  route_table_id = aws_route_table.private_az2.id
}

#-- VPC Gateway Endpoints (S3 and DynamoDB) -----------------------------------
resource "aws_vpc_endpoint" "s3" {
  count           = contains(var.vpc_gateway_endpoints, "S3") ? 1 : 0
  vpc_id          = aws_vpc.main.id
  service_name    = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [
    aws_route_table.private_az1.id,
    aws_route_table.private_az2.id,
  ]

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-vpce-s3"
  })
}

resource "aws_vpc_endpoint" "dynamodb" {
  count           = contains(var.vpc_gateway_endpoints, "DynamoDB") ? 1 : 0
  vpc_id          = aws_vpc.main.id
  service_name    = "com.amazonaws.${data.aws_region.current.name}.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [
    aws_route_table.private_az1.id,
    aws_route_table.private_az2.id,
  ]

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-vpce-dynamodb"
  })
}

data "aws_region" "current" {}
