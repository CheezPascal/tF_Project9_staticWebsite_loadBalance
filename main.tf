provider "aws" {
  region = "us-east-1" # Change to your desired AWS region
}

# ------------------------------
# Security Group for HTTP Access
# ------------------------------
resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Allow HTTP and RDP access"

  ingress {
    description = "HTTP Access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "RDP Access"
    from_port   = 3389
    to_port     = 3389
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

# ------------------------------
# Ubuntu Instances
# ------------------------------
resource "aws_instance" "ubuntu_main" {
  ami                    = "ami-0c55b159cbfafe1f0" # Ubuntu 20.04 Free Tier AMI (us-east-1)
  instance_type          = "t2.micro"
  key_name               = "your-key-pair" # Replace with your key pair name
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y httpd
              echo "<h1>Main Page</h1>" > /var/www/html/index.html
              systemctl start apache2
              systemctl enable apache2
              EOF

  tags = {
    Name = "Ubuntu_Main"
  }
}

resource "aws_instance" "ubuntu_outage" {
  ami                    = "ami-0c55b159cbfafe1f0" # Ubuntu 20.04 Free Tier AMI (us-east-1)
  instance_type          = "t2.micro"
  key_name               = "your-key-pair" # Replace with your key pair name
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y httpd
              echo "<h1>Website Outage</h1>" > /var/www/html/index.html
              systemctl start apache2
              systemctl enable apache2
              EOF

  tags = {
    Name = "Ubuntu_Outage"
  }
}

# ------------------------------
# Windows Instances (Not Load Balanced)
# ------------------------------
resource "aws_instance" "windows1" {
  ami                    = "ami-04e5276ebb8451442" # Windows Server 2019 Base AMI (us-east-1)
  instance_type          = "t2.micro"
  key_name               = "your-key-pair" # Replace with your key pair name
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "Windows1"
  }
}

resource "aws_instance" "windows2" {
  ami                    = "ami-04e5276ebb8451442" # Windows Server 2019 Base AMI (us-east-1)
  instance_type          = "t2.micro"
  key_name               = "your-key-pair" # Replace with your key pair name
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "Windows2"
  }
}

# ------------------------------
# Load Balancer
# ------------------------------
resource "aws_lb" "web_lb" {
  name               = "web-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_sg.id]
  subnets            = data.aws_subnets.default.ids

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "web_tg" {
  name     = "web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    enabled             = true
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "ubuntu_main_attach" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.ubuntu_main.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "ubuntu_outage_attach" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.ubuntu_outage.id
  port             = 80
}

resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.web_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

# ------------------------------
# Outputs
# ------------------------------
output "load_balancer_dns" {
  description = "DNS Name of the Load Balancer"
  value       = aws_lb.web_lb.dns_name
}
