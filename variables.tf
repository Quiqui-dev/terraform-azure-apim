variable "platform_name" {
  type        = string
  nullable    = false
  description = "the name of the platform for this service"
}

variable "service_name" {
  type        = string
  nullable    = false
  description = "the friendly name of this service"
}

variable "environment" {
  type        = string
  nullable    = false
  description = "which environment is being deployed"
  validation {
    condition     = can(regex("[a-z0-9][a-z0-9][a-z0-9]", var.environment))
    error_message = "environment value must be 3 lower case letters or numbers"
  }
}

variable "region" {
  type        = string
  nullable    = false
  description = "The azure region where the rg will be deployed"
}

variable "instance_number" {
  type        = string
  nullable    = false
  description = "user defined, instance number of the environment - 001, 005, 010, etc."
  default     = "001"
}

variable "environment_version" {
  type        = string
  nullable    = false
  default     = "1.00"
  description = "value"
}

variable "persistent_tags" {
  type        = map(string)
  nullable    = false
  description = "A map of tags to be applied to the resource"
}

variable "use_name_override" {
  type        = bool
  nullable    = false
  default     = false
  description = "should the module take a user provided name rather than generating it from the provided variables"
}

variable "name_override" {
  type        = string
  nullable    = true
  default     = null
  description = "the override name to use rather than the module generated naming"
}

variable "resource_group_name" {
  type        = string
  nullable    = false
  description = "The name of the resource group to create the vnet in"
  validation {
    condition     = try(trimspace(var.resource_group_name) != "", false)
    error_message = "resource group name must not be empty"
  }
}

variable "publisher" {
  type = object({
    name  = string,
    email = string
  })
  nullable    = true
  default     = null
  description = "the email and name of the publisher"
}

variable "notification_sender_email" {
  type     = string
  nullable = true
  default  = null
}

variable "sku" {
  type     = string
  nullable = false
}

variable "public_ip_address_id" {
  type     = string
  nullable = true
  default  = null
}

variable "networking_settings" {
  type = object({
    public_network_access_enabled = optional(bool, false)
    virtual_network_type          = optional(string, "None")
    vnet_subnet_id                = optional(string)
  })
}

variable "additional_locations" {
  type = map(object({
    location             = string
    capactity            = optional(number, null)
    zones                = optional(list(string), null)
    public_ip_address_id = optional(string)
    gateway_disabled     = optional(bool, false)
    virtual_network_configuration = object({

    })
  }))
  nullable = true
  default  = null
}

variable "apim_certificates" {
  type = map(object({
    encoded_certificate  = string
    store_name           = string
    certificate_password = optional(string)
  }))
  nullable = true
  default  = null
}

variable "delegations" {
  type = map(object({
    subscriptions_enabled     = optional(bool, false)
    user_registration_enabled = optional(bool, false)
    url                       = optional(string)
    validation_key            = optional(string)
  }))
  nullable = true
  default  = null
}

variable "sign_up_settings" {
  type = object({
    enabled = optional(bool, true)
    tos = object({
      enabled          = optional(bool, true)
      consent_required = optional(bool, true)
      tos_text         = optional(string, "No TOS provided")
    })
  })
  nullable = false
}

variable "main_gateway_disabled" {
  type    = bool
  default = false
}

variable "http2_enabled" {
  type    = bool
  default = false
}

variable "sign_in_enabled" {
  type    = bool
  default = true
}

variable "allow_management_api_access" {
  type    = bool
  default = false
}

variable "availability_zones" {
  type     = list(string)
  nullable = true
  default  = null
}

variable "min_api_version" {
  type     = string
  default  = null
  nullable = true
}

variable "security_settings" {
  type = object({
    backend_ssl30_enabled                               = optional(bool, false)
    backend_tls10_enabled                               = optional(bool, false)
    backend_tls11_enabled                               = optional(bool, false)
    frontend_ssl30_enabled                              = optional(bool, false)
    frontend_tls10_enabled                              = optional(bool, false)
    frontend_tls11_enabled                              = optional(bool, false)
    tls_ecdhe_ecdsa_with_aes128_cbc_sha_ciphers_enabled = optional(bool, false)
    tls_ecdhe_ecdsa_with_aes256_cbc_sha_ciphers_enabled = optional(bool, false)
    tls_ecdhe_rsa_with_aes128_cbc_sha_ciphers_enabled   = optional(bool, false)
    tls_ecdhe_rsa_with_aes256_cbc_sha_ciphers_enabled   = optional(bool, false)
    tls_rsa_with_aes128_cbc_sha256_ciphers_enabled      = optional(bool, false)
    tls_rsa_with_aes128_cbc_sha_ciphers_enabled         = optional(bool, false)
    tls_rsa_with_aes128_gcm_sha256_ciphers_enabled      = optional(bool, false)
    tls_rsa_with_aes256_cbc_sha256_ciphers_enabled      = optional(bool, false)
    tls_rsa_with_aes256_cbc_sha_ciphers_enabled         = optional(bool, false)
    tls_rsa_with_aes256_gcm_sha384_ciphers_enabled      = optional(bool, false)
    triple_des_ciphers_enabled                          = optional(bool, false)
  })
}

variable "custom_gateways" {
  type = map(object({
    key_vault_certificate_id        = optional(string)
    default_ssl_binding             = optional(string)
    certificate                     = optional(string)
    certificate_password            = optional(string)
    negotiate_client_certificate    = optional(bool, false)
    ssl_keyvault_identity_client_id = optional(string)
  }))
  nullable = true
}

variable "custom_dev_portal" {
  type = map(object({
    key_vault_certificate_id        = optional(string)
    certificate                     = optional(string)
    certificate_password            = optional(string)
    negotiate_client_certificate    = optional(bool, false)
    ssl_keyvault_identity_client_id = optional(string)
  }))
  nullable = true
}

variable "custom_management" {
  type = map(object({
    key_vault_certificate_id        = optional(string)
    certificate                     = optional(string)
    certificate_password            = optional(string)
    negotiate_client_certificate    = optional(bool, false)
    ssl_keyvault_identity_client_id = optional(string)
  }))
  nullable = true
}

variable "custom_portal" {
  type = map(object({
    key_vault_certificate_id        = optional(string)
    certificate                     = optional(string)
    certificate_password            = optional(string)
    negotiate_client_certificate    = optional(bool, false)
    ssl_keyvault_identity_client_id = optional(string)
  }))
  nullable = true
}

variable "custom_scm" {
  type = map(object({
    key_vault_certificate_id        = optional(string)
    certificate                     = optional(string)
    certificate_password            = optional(string)
    negotiate_client_certificate    = optional(bool, false)
    ssl_keyvault_identity_client_id = optional(string)
  }))
  nullable = true
}
