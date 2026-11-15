# 1. Create the VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = { Name = "project-vpc" }
}

# 2. Public Subnet (for Web Server)
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = { Name = "project-public-subnet" }
}

# 3. Private Subnet (for Database Server - Secured)
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  tags = { Name = "project-private-subnet" }
}

# 4. Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "project-igw" }
}

# 5. Route Table for Public Subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = { Name = "project-public-rt" }
}

resource "aws_route_table_association" "public_rta" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

# 6. Security Group for Web Server
resource "aws_security_group" "web_sg" {
  name   = "web-server-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Consider restricting this to your specific IP address for better security
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "web-sg" }
}

# 7. Security Group for Database Server (Allows traffic ONLY from Web Server SG)
resource "aws_security_group" "db_sg" {
  name   = "db-server-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 3306 # MySQL port (adjust if using PostgreSQL: 5432)
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "db-sg" }
}

# 8. Random ID generation to ensure globally unique S3 bucket name
resource "random_id" "id" {
  byte_length = 4
}

# 9. S3 Bucket for backups
resource "aws_s3_bucket" "backup_bucket" {
  bucket        = "app-backups-bucket-${random_id.id.hex}"
  force_destroy = true
}

# 10. EC2 Instance (Web Server) in Public Subnet
resource "aws_instance" "web" {
  ami                    = "ami-04a81a99f5ec58529" # Ubuntu 22.04 LTS (Verify region compatibility)
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = { Name = "web-server" }
}

# 11. EC2 Instance (DB Server) in Private Subnet
resource "aws_instance" "db" {
  ami                    = "ami-04a81a99f5ec58529"
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private.id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  tags = { Name = "db-server" }
}
