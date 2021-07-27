terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}

provider "aws" {
   access_key = "AKIAUFITGSV6B4CGB67E"

  secret_key = "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 "
  
  region     = "ap-south-1"
}
resource "aws_vpc" "vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "pullarao"
  }
}
resource "aws_subnet" "Pub" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Public"
  }
}

resource "aws_internet_gateway" "igv" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "igv"
  }
}
resource "aws_eip" "ip" {
    vpc  = true
}

resource "aws_route_table" "rot" {
  vpc_id = aws_vpc.vpc.id

  route  {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igv.id
  }
  tags = {
      name = "route"
  }
}


resource "aws_route_table_association" "as_1" {
  subnet_id      = aws_subnet.Pub.id
  route_table_id = aws_route_table.rot.id
}
resource "aws_security_group" "sg" {
  name        = "first-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]

  }
 egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sachin"
  }
}


resource "aws_instance" "ubuntu-200" {
  ami  = "ami-0c1a7f89451184c8b"
  instance_type = "t2.micro"
      user_data = <<-EOF
      #!/bin/bash
      sudo apt update
      sudo apt install -y apache2
      sudo apt install -y ansible
      EOF
  associate_public_ip_address = true
  subnet_id = aws_subnet.Pub.id
  vpc_security_group_ids = [aws_security_group.sg.id]
  key_name               = "pullarao"
 tags = {
    Name = "ansible_server"
  }

  }
  resource "aws_security_group" "sg_200" {
  name        = "secound-sg200"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.vpc.id
    ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
   }
    ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

 egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ansible-sg200"
  }
}

resource "aws_instance" "ubuntu200" {
  ami  = "ami-0c1a7f89451184c8b"
  instance_type = "t2.micro"
      user_data = <<-EOF
      #!/bin/bash
      sudo apt update
      sudo apt install -y apache2
      EOF
  associate_public_ip_address = true
  subnet_id = aws_subnet.Pub.id
  vpc_security_group_ids = [aws_security_group.sg_200.id]
  key_name               = "pullarao"
 tags = {
    Name = "apache_server"
  }

}
resource "aws_instance" "ubuntu_300" {
  ami  = "ami-0c1a7f89451184c8b"
  instance_type = "t3.micro"
      user_data = <<-EOF
      #!/bin/bash
      sudo apt update
      sudo apt install -y apache2
      EOF
  associate_public_ip_address = true
  subnet_id = aws_subnet.Pub.id
  vpc_security_group_ids = [aws_security_group.sg_200.id]
  key_name               = "pullarao"
 tags = {
    Name = "k8worker"
  }
}
resource "aws_instance" "ubuntu_400" {
  ami  = "ami-0c1a7f89451184c8b"
  instance_type = "t3.micro"
  associate_public_ip_address = true
  subnet_id = aws_subnet.Pub.id
  vpc_security_group_ids = [aws_security_group.sg_200.id]
  key_name               = "pullarao"
 tags = {
    Name = "k8master"
  }
}
