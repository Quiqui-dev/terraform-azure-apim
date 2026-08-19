
output "id" {
  value = azurerm_api_management.this.id
}

output "name" {
  value = azurerm_api_management.this.name
}

output "apim_identity" {
  value = azurerm_api_management.this.identity[0]
}

output "public_ips" {
  value = azurerm_api_management.this.public_ip_addresses
}

output "private_ips" {
  value = azurerm_api_management.this.private_ip_addresses
}

output "custom_domain_id" {
  value = azurerm_api_management_custom_domain.this.id
}
