

#creating vpc 
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "dev"
  }
}


#creating subnet2
resource "aws_subnet" "dev-public-1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-2a"

  tags = {
    Name = "dev-public-1"
  }
}

#creating subnet2
resource "aws_subnet" "dev-public-2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-2b"

  tags = {
    Name = "dev-public-2"
  }
}

#creating igw
resource "aws_internet_gateway" "main-gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "dev"
  }
}

#creating route table
resource "aws_route_table" "main-route" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main-gw.id
  }

  tags = {
    Name = "dev-public-1"
  }
}

#Creating Route Associations public subnets
resource "aws_route_table_association" "dev-public-1-a" {
  subnet_id      = aws_subnet.dev-public-1.id
  route_table_id = aws_route_table.main-route.id
}

#Creating Route Associations public subnets
resource "aws_route_table_association" "dev-public-1-b" {
  subnet_id      = aws_subnet.dev-public-2.id
  route_table_id = aws_route_table.main-route.id
}

#creating security group
resource "aws_security_group" "mysgp" {
  name        = "sgp"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/16"]
  }
   ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/16"]
  }
   ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/16"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  tags = {
    Name = "mysgp1"
  }
}

#creating s3
resource "aws_s3_bucket" "example" {
  bucket = "indrajitmulticmproject23"
}

resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.example.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.example.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


resource "aws_s3_bucket_acl" "example" {
  depends_on = [
    aws_s3_bucket_ownership_controls.example,
    aws_s3_bucket_public_access_block.example,
  ]

  bucket = aws_s3_bucket.example.id
  acl    = "public-read"
}

#Create ec2
resource "aws_instance" "server1"{
    ami =var.ami_value
    instance_type =var.instance_type_value
    vpc_security_group_ids = ["sg-0b329b53a4b87db3b"]
    subnet_id = aws_subnet.dev-public-1.id
    user_data = base64encode(file("usedata.sh"))
  key_name = "indrajeet1"
  tags = {
    Name = "public_inst_1"
  }
  }

  resource "aws_instance" "server2"{
    ami =var.ami_value
    instance_type =var.instance_type_value
    vpc_security_group_ids = ["sg-0b329b53a4b87db3b"]
    subnet_id = aws_subnet.dev-public-1.id
    user_data = base64encode(file("userdata2.sh"))
  key_name = "indrajeet1"
  tags = {
    Name = "public_inst_2"
  }
  }




