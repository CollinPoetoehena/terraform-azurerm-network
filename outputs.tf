# =============================================================================
# Virtual Network Outputs
# =============================================================================

output "vnet_ids" {
  description = "Map of VNet key to VNet resource ID."
  value       = { for k, v in azurerm_virtual_network.main : k => v.id }
}

output "vnet_names" {
  description = "Map of VNet key to VNet name as created in Azure."
  value       = { for k, v in azurerm_virtual_network.main : k => v.name }
}

output "peering_ids" {
  description = "Map of peering key to peering resource ID."
  value       = { for k, v in azurerm_virtual_network_peering.main : k => v.id }
}

# =============================================================================
# Network Security Group Outputs
# =============================================================================

output "nsg_ids" {
  description = "Map of NSG key to NSG resource ID."
  value       = { for k, v in azurerm_network_security_group.main : k => v.id }
}

# =============================================================================
# Subnet Outputs
# =============================================================================

output "subnet_ids" {
  description = "Map of subnet key to subnet resource ID."
  value       = { for k, v in azurerm_subnet.main : k => v.id }
}

output "subnet_names" {
  description = "Map of subnet key to subnet name as created in Azure."
  value       = { for k, v in azurerm_subnet.main : k => v.name }
}
