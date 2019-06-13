# provider
provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}

resource "aws_instance" "one-server" {
  ami                    = "ami-40d28157"
  instance_type          = "t2-micro"
  vpc_security_group_ids = ["${aws_security_group.one-server-sg.id}"]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p "${var.server_port}" &              
              EOF

  tags {
    name = "one_server"
  }
}

resource "aws_security_group" "one-server-sg" {
  name = "one-server-security-group"

  ingress {
    from_port   = "${var.server_port}"
    to_port     = "${var.server_port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "public_ip" {
  value = "${aws_instance.one-server.public_ip}"
}
