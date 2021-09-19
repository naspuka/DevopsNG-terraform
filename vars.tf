variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}
variable "AWS_REGION" {
	default = "eu-west-1"
}
variable "AMIS" {
	type = map
	default = {
		us-east-1 = "ami-0133407e358cc1af0"
		us-west-2 = "ami-03ac21435677d3cb3"
		eu-west-1 = "ami-016ee74f2cf016914"
	}
}
variable "server_port" {
	description = "server is hosted on this port"
	type = number
	default = 8080
}
output "public_ip" {
	value = aws_instance.example.public_ip
	description = "public IP of the web server"
}
output "clb_dns_name" {
	value = "aws_elb.example.dns_name"
	description = "domain name for load balancer"
}