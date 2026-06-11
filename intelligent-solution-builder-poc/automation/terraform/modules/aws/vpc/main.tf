###############################################################################
# Tier 1 Provider Module — AWS VPC
# Creates VPC, subnets (public + private), IGW, NAT Gateways, route tables,
# and VPC Interface Endpoints (PrivateLink) for the ISB platform.
###############################################################################

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-vpc"
  })
}

#--------------------------------------
# Internet Gateway
#--------------------------------------
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-igw"
  })
}

#--------------------------------------
# Public subnets
#--------------------------------------
resource "aws_subnet" "public" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  map_public_ip_on_launch = false

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-public-${count.index + 1}"
    Tier = "public"
  })
}

#--------------------------------------
# Private subnets
#--------------------------------------
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-private-${count.index + 1}"
    Tier = "private"
  })
}

#--------------------------------------
# NAT Gateways (one per AZ in prod/dr)
#--------------------------------------
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
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-nat-${count.index + 1}"
  })

  depends_on = [aws_internet_gateway.main]
}

#--------------------------------------
# Route tables — public
#--------------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-rt-public"
  })
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

#--------------------------------------
# Route tables — private (one per NAT GW)
#--------------------------------------
resource "aws_route_table" "private" {
  count  = var.nat_gateway_count
  vpc_id = aws_vpc.main.id
  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-rt-private-${count.index + 1}"
  })
}

resource "aws_route" "private_nat" {
  count                  = var.nat_gateway_count
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[count.index].id
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[min(count.index, var.nat_gateway_count - 1)].id
}

#--------------------------------------
# Security Group — Lambda execution
#--------------------------------------
resource "aws_security_group" "lambda" {
  name        = "${var.name_prefix}-lambda-sg"
  description = "Security group for Lambda function VPC execution"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS egress for AWS service calls"
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-lambda-sg"
  })
}

#--------------------------------------
# Security Group — VPC Endpoints
#--------------------------------------
resource "aws_security_group" "vpc_endpoints" {
  name        = "${var.name_prefix}-vpce-sg"
  description = "Security group for VPC Interface Endpoints"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.lambda.id]
    description     = "HTTPS from Lambda"
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-vpce-sg"
  })
}

#--------------------------------------
# Gateway Endpoints (free)
#--------------------------------------
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = aws_route_table.private[*].id

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-vpce-s3"
  })
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = aws_route_table.private[*].id

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-vpce-dynamodb"
  })
}

#--------------------------------------
# Interface Endpoints (PrivateLink)
#--------------------------------------
resource "aws_vpc_endpoint" "bedrock_runtime" {
  count               = var.enable_privatelink_endpoints ? 1 : 0
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.bedrock-runtime"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-vpce-bedrock-runtime"
  })
}

resource "aws_vpc_endpoint" "secretsmanager" {
  count               = var.enable_privatelink_endpoints ? 1 : 0
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-vpce-secretsmanager"
  })
}

resource "aws_vpc_endpoint" "sqs" {
  count               = var.enable_privatelink_endpoints ? 1 : 0
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.sqs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-vpce-sqs"
  })
}

resource "aws_vpc_endpoint" "ses" {
  count               = var.enable_privatelink_endpoints ? 1 : 0
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.email-smtp"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-vpce-ses"
  })
}
