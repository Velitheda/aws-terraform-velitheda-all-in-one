output "public_ip" {
  value       = aws_instance.web_server_01_jasmine.public_ip
  description = "The public IP of the web server"
}

output "public_dns" {
  value       = aws_instance.web_server_01_jasmine.public_dns
  description = "The public DNS of the web server"
}
