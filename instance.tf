resource "aws_instance" "example" {
	ami = "${lookup(var.AMIS, var.AWS_REGION)}"
	instance_type = "t2.micro"
	vpc_security_group_ids = [aws_security_group.instance.id]

	user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p "${var.server_port}" &
              EOF

	lifecycle {
		create_before_destroy = true
	}
	
	tags = {
    	Name = "terraform-example"
    }
}

resource "aws_security_group" "instance" {
	name = "terraform-example-instance"

	ingress {
		from_port = "${var.server_port}"
		to_port = "${var.server_port}"
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
}

data "aws_availability_zones" "available" {
  state = "available"
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

	owners = ["099720109477"] # Canonical
}

resource "aws_launch_configuration" "as_conf" {
	name_prefix   = "terraform-lc-example-"
	image_id      = data.aws_ami.ubuntu.id
	instance_type = "t2.micro"

	lifecycle {
		create_before_destroy = true
	}
}

resource "aws_autoscaling_group" "example" {
	launch_configuration  = aws_launch_configuration.as_conf.name
	availability_zones = data.aws_availability_zones.available.names	

	min_size = 2
	max_size = 20

	load_balancers = [aws_elb.example.name]
	health_check_type = "ELB"

	tag {
		key = "Name"
		value = "terraform-asg-example"
		propagate_at_launch = true
	}
}

resource "aws_elb" "example" {
	name = "terraform-asg-example"
	security_groups = [aws_security_group.elb.id]
	availability_zones = data.aws_availability_zones.available.names

	health_check {
		target = "HTTP:${var.server_port}/"
		interval = 30
		timeout = 3
		healthy_threshold = 2
		unhealthy_threshold = 2
	}
	# This adds a listener for http request; this reroutes request enabling load balancing
	listener {
		lb_port = 80
		lb_protocol = "http"
		instance_port = 	"${var.server_port}"
		instance_protocol = "http"
	}
}

resource "aws_security_group" "elb" {
	name = "terraform-example-elb"

	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
	ingress {
		from_port = 80
		to_port = 80
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
}