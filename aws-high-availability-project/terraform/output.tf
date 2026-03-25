output "private_instance_ip"{
    value = aws_instance.web.private_ip
    description = "Private Instance"
}

output "public_instance_ip"{
    value = aws_instance.web.public_ip
    description = "Public Instance"
    
    }
