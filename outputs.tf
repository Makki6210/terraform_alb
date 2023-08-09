output "web_public_ips" {
  value = [for i in aws_instance.web_server : i.public_ip]
}

output "alb_dns_name" {
  value = aws_lb.my_lb.dns_name
}
