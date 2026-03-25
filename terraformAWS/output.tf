output "private_instance_ip" {
  value       = aws_instance.web.private_ip
  description = "Instancia Privada"
}
output "public_ip"{
  value = aws_instance.web.public.ip
  description = "Instancia Publica"
}