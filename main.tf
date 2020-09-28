provider "aws" {
    region = "us-east-1"
}

##AWS INSTANCE##

resource "aws_instance" "example" {
    #ubuntu 18.04 free tier
  ami           = "ami-0817d428a6fb68645"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.instance.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hola mundo!" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF
  tags = {
    Name = "EC2-Coque"
  }
}
##AWS SECURITY GROUP##

resource "aws_security_group" "instance" {
  name = "terraform_example-instance"

  ingress{
   from_port = var.server_port
   to_port   = var.server_port
   protocol  = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
  }
  ingress{
   from_port = var.ssh_port
   to_port   = var.ssh_port
   protocol  = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
  }
   egress{
   from_port = var.server_port
   to_port   = var.server_port
   protocol  = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
  }
}

/*resource "aws_key_pair" "deployer" {
  key_name = "deployer-key"
  public_key = "ssh-rsa "
}*/

/*##AWS LAUNCH CONFIGURATION##

resource "aws_launch_configuration" "example" {
  image_id = "ami-0817d428a6fb68645"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.instance.id]

  user_data = <<-EOF
              #!/bin/bash
                echo "Hola, Mundo" > index.html
                nohup busybox httpd -f -p ${var.server_port} &
                EOF
  
  lifecycle {
    create_before_destroy = true
  }
}

##AWS AUTOSCALING GROUP##

resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.example.name
  vpc_zone_identifier = data.aws_subnet_ids.default.ids
  

  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  min_size = 2
  max_size = 10

  tag {
    key = "Name"
    value = "terraform_asg_example"
    propagate_at_launch = true
  }
}

##APPLICATION LOAD BALANCER##}

resource "aws_lb" "example" {
  name =               "terraform-alb-example"
  load_balancer_type = "application"
  subnets            = data.aws_subnet_ids.default.ids
  security_groups    = [aws_security_group.alb.id]
}

##ALB LISTENER CONFIGURATION##
resource "aws_lb_listener" "http" {
load_balancer_arn = aws_lb.example.arn
port              = 80
protocol          = "HTTP"

#by default, return a simple 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404_ page not found"
      status_code = 404
    }
  }
}
##ALB SECURITY GROUP##
resource "aws_security_group" "alb" {
  name = "terraform-example-alb"
  
  #Allow inbound HTTP requests
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

##ALB TARGET GROUP##

resource "aws_lb_target_group" "asg" {
  name = "terraform-asg-example"
  port = var.server_port
  protocol = "HTTP"
  vpc_id = data.aws_vpc.default.id

  health_check {
    path =      "/"
    protocol =  "HTTP"
    matcher =   "200"
    interval =  15
    timeout =   3
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}
##ALB LISTENER RULE##

resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type    = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}

##AWS VARIABLES##
*/
variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}
variable "ssh_port" {
  description = "Port to connect via ssh"
  type        = number
  default     = 443
}
/*
##AWS OUTPUTS##

output "public_ip" {
  value = aws_instance.example.public_ip
  description = "La IP púterraforblica de mi servidor"
}

output "alb_dns_name" {
  value = aws_lb.example.dns_name
  description = "The domain name of the load balancer"
}

##DATA##

data "aws_vpc" "default" {
  default = true
}
data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}*/