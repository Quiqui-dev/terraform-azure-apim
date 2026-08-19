# Written By: Kieran Mitchell
# Date: 18/08/26
# Module Purpose: The apim module, should provision an azure api management platform resource
# and any custom domains, with relevant permissions to access key vault.

locals {

  region_short_name = substr(var.region, 0, 3)
  apim_name         = var.use_name_override == true ? var.name_override : lower("${var.platform_name}-${local.region_short_name}-${var.environment}-${var.environment_version}-${var.instance_number}-${var.service_name}-apim")

  notification_sender_email = try(coalesce(var.notification_sender_email, ""), false) ? var.publisher.email : var.notification_sender_email
}

resource "azurerm_api_management" "this" {
  name                          = local.apim_name
  location                      = var.region
  resource_group_name           = var.resource_group_name
  publisher_name                = var.publisher.name
  publisher_email               = var.publisher.email
  notification_sender_email     = local.notification_sender_email
  public_ip_address_id          = var.public_ip_address_id
  public_network_access_enabled = var.networking_settings.public_network_access_enabled
  sku_name                      = var.sku
  virtual_network_type          = var.networking_settings.virtual_network_type
  gateway_disabled              = var.main_gateway_disabled
  min_api_version               = var.min_api_version
  zones                         = var.availability_zones

  dynamic "virtual_network_configuration" {
    for_each = contains(["External", "Internal"], var.networking_settings.virtual_network_type) ? [1] : []
    content {
      subnet_id = var.networking_settings.vnet_subnet_id
    }
  }

  dynamic "additional_location" {
    for_each = var.additional_locations
    iterator = this
    content {
      location             = this.value.location
      capacity             = this.value.capactity
      zones                = this.value.zones
      public_ip_address_id = this.value.public_ip_address_id
      gateway_disabled     = this.value.gateway_disabled
    }
  }

  dynamic "delegation" {
    for_each = var.delegations
    iterator = this
    content {
      subscriptions_enabled     = this.value.subscriptions_enabled
      user_registration_enabled = this.value.user_registration_enabled
      url                       = this.value.url
      validation_key            = this.value.validation_key
    }
  }

  dynamic "certificate" {
    for_each = var.apim_certificates
    iterator = this
    content {
      encoded_certificate  = this.value.encoded_certificate
      store_name           = this.value.store_name
      certificate_password = this.value.certificate_password
    }
  }

  protocols {
    http2_enabled = var.http2_enabled
  }

  security {
    backend_ssl30_enabled                               = var.security_settings.backend_ssl30_enabled
    backend_tls10_enabled                               = var.security_settings.backend_tls10_enabled
    backend_tls11_enabled                               = var.security_settings.backend_tls11_enabled
    frontend_ssl30_enabled                              = var.security_settings.frontend_ssl30_enabled
    frontend_tls10_enabled                              = var.security_settings.frontend_tls10_enabled
    frontend_tls11_enabled                              = var.security_settings.frontend_tls11_enabled
    tls_ecdhe_ecdsa_with_aes128_cbc_sha_ciphers_enabled = var.security_settings.tls_ecdhe_ecdsa_with_aes128_cbc_sha_ciphers_enabled
    tls_ecdhe_ecdsa_with_aes256_cbc_sha_ciphers_enabled = var.security_settings.tls_ecdhe_ecdsa_with_aes256_cbc_sha_ciphers_enabled
    tls_ecdhe_rsa_with_aes128_cbc_sha_ciphers_enabled   = var.security_settings.tls_ecdhe_rsa_with_aes128_cbc_sha_ciphers_enabled
    tls_ecdhe_rsa_with_aes256_cbc_sha_ciphers_enabled   = var.security_settings.tls_ecdhe_rsa_with_aes256_cbc_sha_ciphers_enabled
    tls_rsa_with_aes128_cbc_sha256_ciphers_enabled      = var.security_settings.tls_rsa_with_aes128_cbc_sha256_ciphers_enabled
    tls_rsa_with_aes128_cbc_sha_ciphers_enabled         = var.security_settings.tls_rsa_with_aes128_cbc_sha_ciphers_enabled
    tls_rsa_with_aes128_gcm_sha256_ciphers_enabled      = var.security_settings.tls_rsa_with_aes128_gcm_sha256_ciphers_enabled
    tls_rsa_with_aes256_cbc_sha256_ciphers_enabled      = var.security_settings.tls_rsa_with_aes256_cbc_sha256_ciphers_enabled
    tls_rsa_with_aes256_cbc_sha_ciphers_enabled         = var.security_settings.tls_rsa_with_aes256_cbc_sha_ciphers_enabled
    tls_rsa_with_aes256_gcm_sha384_ciphers_enabled      = var.security_settings.tls_rsa_with_aes256_gcm_sha384_ciphers_enabled
    triple_des_ciphers_enabled                          = var.security_settings.triple_des_ciphers_enabled
  }

  sign_in {
    enabled = var.sign_in_enabled
  }

  sign_up {
    enabled = var.sign_up_settings.enabled
    terms_of_service {
      enabled          = var.sign_up_settings.tos.enabled
      consent_required = var.sign_up_settings.tos.consent_required
      text             = var.sign_up_settings.tos.tos_text
    }
  }

  tenant_access {
    enabled = var.allow_management_api_access
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.persistent_tags
}

resource "azurerm_api_management_custom_domain" "this" {
  api_management_id = azurerm_api_management.this.id

  dynamic "gateway" {
    for_each = var.custom_gateways
    content {
      host_name                       = gateway.key
      key_vault_certificate_id        = gateway.value.key_vault_certificate_id
      default_ssl_binding             = gateway.value.default_ssl_binding
      certificate                     = gateway.value.certificate
      certificate_password            = gateway.value.certificate_password
      negotiate_client_certificate    = gateway.value.negotiate_client_certificate
      ssl_keyvault_identity_client_id = gateway.value.ssl_keyvault_identity_client_id
    }
  }

  dynamic "developer_portal" {
    for_each = var.custom_dev_portal

    content {
      host_name                       = developer_portal.key
      key_vault_certificate_id        = developer_portal.value.key_vault_certificate_id
      certificate                     = developer_portal.value.certificate
      certificate_password            = developer_portal.value.certificate_password
      negotiate_client_certificate    = developer_portal.value.negotiate_client_certificate
      ssl_keyvault_identity_client_id = developer_portal.value.ssl_keyvault_identity_client_id
    }
  }

  dynamic "management" {
    for_each = var.custom_management

    content {
      host_name                       = management.key
      key_vault_certificate_id        = management.value.key_vault_certificate_id
      certificate                     = management.value.certificate
      certificate_password            = management.value.certificate_password
      negotiate_client_certificate    = management.value.negotiate_client_certificate
      ssl_keyvault_identity_client_id = management.value.ssl_keyvault_identity_client_id
    }
  }

  dynamic "portal" {
    for_each = var.custom_portal

    content {
      host_name                       = portal.key
      key_vault_certificate_id        = portal.value.key_vault_certificate_id
      certificate                     = portal.value.certificate
      certificate_password            = portal.value.certificate_password
      negotiate_client_certificate    = portal.value.negotiate_client_certificate
      ssl_keyvault_identity_client_id = portal.value.ssl_keyvault_identity_client_id
    }
  }

  dynamic "scm" {
    for_each = var.custom_scm

    content {
      host_name                       = scm.key
      key_vault_certificate_id        = scm.value.key_vault_certificate_id
      certificate                     = scm.value.certificate
      certificate_password            = scm.value.certificate_password
      negotiate_client_certificate    = scm.value.negotiate_client_certificate
      ssl_keyvault_identity_client_id = scm.value.ssl_keyvault_identity_client_id
    }
  }
}
