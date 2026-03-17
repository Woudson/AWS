resource "aws_instance" "web" {
    ami = "ami-06a73f9d93a3879b5"
    instance_type = var.instance_type
}