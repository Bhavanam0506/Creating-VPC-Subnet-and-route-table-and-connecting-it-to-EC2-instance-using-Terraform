
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region     = "ap-south-1"
  access_key = "your access key"
  secret_key = "your secret key"
}
resource "aws_vpc" "myvpc" {
  cidr_block       = "10.0.0.0/22"
  instance_tenancy = "default"
  enable_dns_support = "true"
  enable_dns_hostnames = "true"
 

  tags = {
    Name = "bhavana"
  }
}
resource "aws_subnet" "publicsubnet" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.0.0/26"
  map_public_ip_on_launch = "true"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "publicsubnet"
  }
}
resource "aws_subnet" "privatesubnet" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.1.0/26"
  map_public_ip_on_launch = "false"
  availability_zone = "ap-south-1b"


  tags = {
    Name = "privatesubnet"
  }
}
resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "myigw"
  }
}
resource "aws_route_table" "publicrt" {
  vpc_id = aws_vpc.myvpc.id

  # since this is exactly the route AWS will create, the route will be adopted
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myigw.id
  }
  tags = {
    Name = "publicrt"
  }
}
resource "aws_route_table" "privatert" {
  vpc_id = aws_vpc.myvpc.id

  # since this is exactly the route AWS will create, the route will be adopted
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myigw.id
  }
  tags = {
    Name = "privatert"
  }
}
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.publicsubnet.id
  route_table_id = aws_route_table.publicrt.id
}
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.privatesubnet.id
  route_table_id = aws_route_table.privatert.id
}

resource "aws_instance" "publicec2" {
  ami           = "ami-0a0f1259dd1c90938"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.publicsubnet.id
  tags = {
    Name = "publicec2"
  }
}
resource "aws_instance" "privateec2" {
  ami           = "ami-0a0f1259dd1c90938"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.privatesubnet.id
  tags = {
    Name = "privateec2"
  }
}
