output "public_dns_x86_64" {
  value       = aws_instance.compat-layer-builder-x86_64.*.public_dns
}

output "public_dns_arm" {
  value       = aws_instance.compat-layer-builder-arm.*.public_dns
}

