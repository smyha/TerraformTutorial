# ============================================================================
# Azure Network Watcher Module - Main Configuration
# ============================================================================
# Network Watcher provides tools to monitor, diagnose, and view metrics
# for your Azure network infrastructure.
#
# Key Features:
# - Topology visualization
# - Connection monitoring
# - Packet capture
# - IP flow verify
# - Next hop analysis
# - VPN troubleshooting
# - NSG flow logs
# ============================================================================

# ----------------------------------------------------------------------------
# Network Watcher
# ----------------------------------------------------------------------------
# Network Watcher is automatically created in each Azure region.
# However, we can explicitly create it to ensure it exists and configure it.
#
# Note: Network Watcher is a regional service. One instance per region.
# The name is typically 'NetworkWatcher_{region}' (e.g., 'NetworkWatcher_eastus').
# ----------------------------------------------------------------------------
resource "azurerm_network_watcher" "main" {
  name                = var.network_watcher_name != null ? var.network_watcher_name : "NetworkWatcher_${replace(var.location, " ", "")}"
  location            = var.location
  resource_group_name = var.resource_group_name
  
  tags = var.tags
}

# ----------------------------------------------------------------------------
# NSG Flow Logs
# ----------------------------------------------------------------------------
# NSG Flow Logs capture information about IP traffic flowing through NSGs.
# They help with:
# - Network monitoring
# - Security analysis
# - Compliance
# - Troubleshooting
#
# Flow Log Versions:
# - Version 1: Legacy format
# - Version 2: Enhanced format with additional fields
# ----------------------------------------------------------------------------
resource "azurerm_network_watcher_flow_log" "main" {
  for_each = var.enable_flow_logs ? var.flow_logs : {}
  
  name                      = each.key
  network_watcher_name      = azurerm_network_watcher.main.name
  resource_group_name       = var.resource_group_name
  network_security_group_id = each.value.network_security_group_id
  storage_account_id        = each.value.storage_account_id
  enabled                   = each.value.enabled
  retention_policy {
    enabled = each.value.retention_days > 0
    days    = each.value.retention_days
  }
  
  # Traffic Analytics (optional)
  dynamic "traffic_analytics" {
    for_each = each.value.traffic_analytics != null ? [each.value.traffic_analytics] : []
    content {
      enabled               = traffic_analytics.value.enabled
      workspace_id          = traffic_analytics.value.workspace_id
      workspace_region      = traffic_analytics.value.workspace_region
      workspace_resource_id = traffic_analytics.value.workspace_resource_id
      interval_in_minutes   = traffic_analytics.value.interval_in_minutes
    }
  }
  
  tags = merge(var.tags, each.value.tags)
}

# ----------------------------------------------------------------------------
# Connection Monitors
# ----------------------------------------------------------------------------
# Connection Monitors test connectivity between endpoints and provide:
# - Connectivity monitoring
# - Latency measurement
# - Path analysis
# - Troubleshooting information
#
# Note: Connection Monitors are created using azurerm_network_connection_monitor
# but the resource structure is complex. For simplicity, this module provides
# the foundation. Connection monitors can be created via Azure Portal or
# separate configurations.
# ----------------------------------------------------------------------------

