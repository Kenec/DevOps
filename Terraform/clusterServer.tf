provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_access_key}"
}

resource "aws_launch_configuration" "cluster-server" {
  image_id        = "ami-40d28157"
  instance_type   = "t2.micro"
  security_groups = "${aws_security_group.cluster-server-sg.id}"

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p "${var.server_port}" &
              EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "cluster-server-sg" {
  name = "cluster-security-group"

  ingress {
    from_port   = "${var.server_port}"
    to_port     = "${var.server_port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "cluster-server-asg" {
  launch_configuration = "${aws_launch_configuration.cluster-server.id}"
  availability_zones   = ["${data.aws_availability_zones.all.names}"]
  min_size             = 2
  max_size             = 10

  tag {
    key                 = "Name"
    value               = "ASG-Cluster"
    propagate_at_launch = true
  }
}

resource "aws_elb" "cluster-elb" {
  name               = "cluster-elb"
  availability_zones = ["${data.aws_availability_zones.all.names}"]

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = "${var.server_port}"
    instance_protocol = "http"
  }
}

data "aws_availability_zones" "all" {}
