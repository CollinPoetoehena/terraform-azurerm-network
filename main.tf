# =============================================================================
# terraform-azurerm-network - Azure Network Stack
# =============================================================================
# Creates a complete Azure network topology:
#   - Virtual Networks + optional VNet peering
#   - Network Security Groups with dynamic security rules
#   - Subnets + optional NSG associations
# =============================================================================

# -----------------------------------------------------------------------------
# Virtual Networks
# -----------------------------------------------------------------------------

// https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network
resource "azurerm_virtual_network" "main" {
  for_each            = var.vnets
  name                = each.key
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [each.value.address_space]
}

// VNet peering is unidirectional in Azure; declare both sides for bidirectional connectivity.
// https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering
resource "azurerm_virtual_network_peering" "main" {
  for_each = var.peerings

  name                      = each.key
  resource_group_name       = var.resource_group_name
  // Directly use the name and id of the VNets from azurerm_virtual_network to avoid hardcoding strings here
  // This also establishes an implicit dependency, ensuring VNets are created before peerings
  virtual_network_name      = azurerm_virtual_network.main[each.value.vnet_key].name
  remote_virtual_network_id = azurerm_virtual_network.main[each.value.remote_vnet_key].id
  allow_forwarded_traffic   = each.value.allow_forwarded_traffic
  allow_gateway_transit     = each.value.allow_gateway_transit
  use_remote_gateways       = each.value.use_remote_gateways
}

# -----------------------------------------------------------------------------
# Network Security Groups
# -----------------------------------------------------------------------------

// https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group
resource "azurerm_network_security_group" "main" {
  for_each            = var.nsgs
  name                = each.key
  location            = var.location
  resource_group_name = var.resource_group_name

  dynamic "security_rule" {
    for_each = each.value.security_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
}

# -----------------------------------------------------------------------------
# Subnets
# -----------------------------------------------------------------------------

// https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet
// References azurerm_virtual_network.main[...].name (not a raw string) to establish
// an implicit dependency so Terraform creates VNets before subnets.
resource "azurerm_subnet" "main" {
  for_each             = var.subnets
  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main[each.value.vnet_key].name
  address_prefixes     = [each.value.address_prefix]
}

// https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association
// Keys in var.nsg_associations are statically defined by the caller,
// satisfying Terraform's requirement that for_each keys be known at plan time.
resource "azurerm_subnet_network_security_group_association" "main" {
  for_each = var.nsg_associations

  subnet_id                 = azurerm_subnet.main[each.key].id
  network_security_group_id = azurerm_network_security_group.main[each.value].id
}
