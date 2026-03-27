# =============================================================================
# Shared
# =============================================================================

variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created."
  type        = string
}

# =============================================================================
# Network Variables
# =============================================================================

# ---------------------------------------------------------------------------
# Virtual Networks
# ---------------------------------------------------------------------------

variable "vnets" {
  description = "Map of Virtual Networks to create. The map key is used as the VNet name in Azure."
  type = map(object({
    address_space = string
  }))
  default = {} // Default to empty map to allow creating zero VNets without errors
}

variable "peerings" {
  description = "Flat map of VNet peering connections. The map key is used as the peering name in Azure. Azure peering is unidirectional; declare both sides for full mesh connectivity. remote_vnet_key must reference a key in var.vnets; the resource ID is resolved internally."
  type = map(object({
    vnet_key                = string // Key from var.vnets — the local VNet that initiates the peering
    remote_vnet_key         = string // Key from var.vnets — the remote VNet to peer with; ID resolved internally
    allow_forwarded_traffic = optional(bool, false)
    allow_gateway_transit   = optional(bool, false)
    use_remote_gateways     = optional(bool, false)
  }))
  default = {} // Default to empty map to allow creating VNets without peerings
}

# ---------------------------------------------------------------------------
# Network Security Groups
# ---------------------------------------------------------------------------

variable "nsgs" {
  description = "Map of Network Security Groups to create. The map key is used as the NSG name in Azure."
  type = map(object({
    security_rules = optional(list(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = string
      destination_port_range     = string
      source_address_prefix      = string
      destination_address_prefix = string
    })), [])
  }))
  default = {} // Default to empty map to allow creating zero NSGs without errors
}

# ---------------------------------------------------------------------------
# Subnets
# ---------------------------------------------------------------------------

variable "subnets" {
  description = "Map of subnets to create. The map key is used as the subnet name in Azure."
  type = map(object({
    vnet_key       = string // Key from var.vnets — resolved to a VNet name internally
    address_prefix = string
  }))
  default = {} // Default to empty map to allow creating VNets without subnets
}

variable "nsg_associations" {
  description = "Map of subnet name to NSG key (from var.nsgs). Keys must match keys in var.subnets. Kept separate so keys are statically known at plan time, satisfying Terraform's for_each requirement."
  type        = map(string)
  default     = {} // Default to empty map to allow creating subnets without NSG associations
}
