#------------------------------------------------------------------------------
# Tier 1: AWS VPC — Private network with 3-AZ subnets, NAT Gateway, VPC endpoints
# Purpose-built VPC isolating Lambda and AgentCore from public internet
#------------------------------------------------------------------------------

data "aws_availability_zones" "available" {
  state = "available"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-vpc"
  })
}

# Internet Gateway (for public subnet / NAT Gateway)
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-igw"
  })
}

# Private subnets — host Lambda and AgentCore across 3 AZs
resource "aws_subnet" "private_az1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_private_az1_cidr
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-private-${data.aws_availability_zones.available.names[0]}"
    Tier = "Private"
  })
}

resource "aws_subnet" "private_az2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_private_az2_cidr
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-private-${data.aws_availability_zones.available.names[1]}"
    Tier = "Private"
  })
}

resource "aws_subnet" "private_az3" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_private_az3_cidr
  availability_zone = data.aws_availability_zones.available.names[2]

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-private-${data.aws_availability_zones.available.names[2]}"
    Tier = "Private"
  })
}

# Public subnet — NAT Gateway only
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_public_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-public-${data.aws_availability_zones.available.names[0]}"
    Tier = "Public"
  })
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  count  = var.nat_gateway_count
  domain = "vpc"

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-nat-eip-${count.index + 1}"
  })

  depends_on = [aws_internet_gateway.main]
}

# NAT Gateway — handles GitHub API and PyPI egress only
resource "aws_nat_gateway" "main" {
  count         = var.nat_gateway_count
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public.id

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-nat-gw-${count.index + 1}"
  })

  depends_on = [aws_internet_gateway.main]
}

# Public route table
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

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Private route tables (egress via NAT)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[0].id
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-rt-private"
  })
}

resource "aws_route_table_association" "private_az1" {
  subnet_id      = aws_subnet.private_az1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_az2" {
  subnet_id      = aws_subnet.private_az2.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_az3" {
  subnet_id      = aws_subnet.private_az3.id
  route_table_id = aws_route_table.private.id
}

# Lambda security group — default-deny, egress to VPC endpoints and NAT only
resource "aws_security_group" "lambda" {
  name        = "${var.name_prefix}-lambda-sg"
  description = "Security group for Lambda functions — egress to VPC endpoints and NAT Gateway"
  vpc_id      = aws_vpc.main.id

  egress {
    description = "HTTPS egress to AWS services via VPC endpoints and NAT"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-lambda-sg"
  })
}

# VPC Endpoints for internal AWS service traffic (avoids NAT charges for Bedrock/DynamoDB/S3)
resource "aws_vpc_endpoint" "s3" {
  count           = var.vpc_endpoints_enabled ? 1 : 0
  vpc_id          = aws_vpc.main.id
  service_name    = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [aws_route_table.private.id]

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-vpce-s3"
  })
}

resource "aws_vpc_endpoint" "dynamodb" {
  count             = var.vpc_endpoints_enabled ? 1 : 0
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private.id]

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-vpce-dynamodb"
  })
}

resource "aws_vpc_endpoint" "secretsmanager" {
  count               = var.vpc_endpoints_enabled ? 1 : 0
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_az1.id, aws_subnet.private_az2.id, aws_subnet.private_az3.id]
  security_group_ids  = [aws_security_group.lambda.id]
  private_dns_enabled = true

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-vpce-secretsmanager"
  })
}

resource "aws_vpc_endpoint" "logs" {
  count               = var.vpc_endpoints_enabled ? 1 : 0
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_az1.id, aws_subnet.private_az2.id, aws_subnet.private_az3.id]
  security_group_ids  = [aws_security_group.lambda.id]
  private_dns_enabled = true

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-vpce-logs"
  })
}

resource "aws_vpc_endpoint" "ecr_api" {
  count               = var.vpc_endpoints_enabled ? 1 : 0
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_az1.id, aws_subnet.private_az2.id, aws_subnet.private_az3.id]
  security_group_ids  = [aws_security_group.lambda.id]
  private_dns_enabled = true

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-vpce-ecr-api"
  })
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  count               = var.vpc_endpoints_enabled ? 1 : 0
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_az1.id, aws_subnet.private_az2.id, aws_subnet.private_az3.id]
  security_group_ids  = [aws_security_group.lambda.id]
  private_dns_enabled = true

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-vpce-ecr-dkr"
  })
}

resource "aws_vpc_endpoint" "states" {
  count               = var.vpc_endpoints_enabled ? 1 : 0
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.states"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_az1.id, aws_subnet.private_az2.id, aws_subnet.private_az3.id]
  security_group_ids  = [aws_security_group.lambda.id]
  private_dns_enabled = true

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-vpce-states"
  })
}

resource "aws_vpc_endpoint" "bedrock" {
  count               = var.vpc_endpoints_enabled ? 1 : 0
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.bedrock-runtime"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_az1.id, aws_subnet.private_az2.id, aws_subnet.private_az3.id]
  security_group_ids  = [aws_security_group.lambda.id]
  private_dns_enabled = true

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-vpce-bedrock"
  })
}
