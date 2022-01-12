provider "aws" {
  region = var.region
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "main-jasmine"
  }
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "main-jasmine"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main-jasmine"
  }
}

resource "aws_default_route_table" "main" {
  default_route_table_id = aws_vpc.main.default_route_table_id
  tags = {
    "Name" = "main-jasmine"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_security_group" "allow_inbound_http" {
  name        = "allow-inbound-http"
  description = "Allow inbound HTTP traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 8080
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_outbound_traffic" {
  name        = "allow-outbound-traffic"
  description = "Allow all outbound traffic"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_instance" "web_server_01_jasmine" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.main.id
  user_data     = <<EOT
  package_update: true
  packages:
  - nginx
  write_files:
  - content: |
      <html>
      <body>
        <p> Hello Jasmine </p>
      </body>
      </html>
    path: /usr/share/app/index.html
    permissions: '0644'
runcmd:
- cp /usr/share/app/index.html /usr/share/nginx/html/index.html
EOT

  tags = {
    Name = "web-server-01-jasmine"
  }

  vpc_security_group_ids = [
    aws_security_group.allow_inbound_http.id,
    aws_security_group.allow_outbound_traffic.id,
  ]
}
