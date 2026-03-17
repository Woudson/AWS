provider "aws" {
  region = "sa-east-1"
}

# 🔐 VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "vpc-terraform"
  }
}

# 🌐 Subnet
resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "sa-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-terraform"
  }
}

# 🌍 Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

# 🛣️ Route Table
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# 🔗 Associação
resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.rt.id
}

# 🔥 Security Group
resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 🖥️ EC2
resource "aws_instance" "web" {
  ami           = "ami-06a73f9d93a3879b5"
  instance_type = "t2.micro"

  subnet_id              = aws_subnet.subnet.id
  vpc_security_group_ids = [aws_security_group.sg.id]

  associate_public_ip_address = true
  key_name                    = "RSA_ServerPub"
  depends_on = [
  aws_subnet.subnet,
  aws_internet_gateway.igw
]

  tags = {
    Name = "terraform-ec2"
  }
}

# 📡 Output
output "public_ip" {
  value = aws_instance.web.public_ip
}