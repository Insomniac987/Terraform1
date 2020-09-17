provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "example" {
    #ubuntu 18.04 free tier
  ami           = "ami-0817d428a6fb68645"
  instance_type = "t2.micro"
  tags = {
    Name = "EC2-Coque"
  }
}