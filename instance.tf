provider "aws" {
	access_key = "AKIASFCQFLIDWUCD2663"
	secret_key = "zPCuJptvKZaHGiVQS9x4J7yV+YNOH0dLj7HRqvOV"
	region = "eu-west-1"
}

resource "aws_instance" "example" {
	ami = "ami-016ee74f2cf016914"
	instance_type = "t2.micro"
}
