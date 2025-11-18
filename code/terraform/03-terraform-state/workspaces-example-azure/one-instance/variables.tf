# ================================================================================
# INPUT VARIABLES FOR AZURE WORKSPACES EXAMPLE
# ================================================================================
# These variables define the Azure resources that can be customized

variable "azure_subscription_id" {
  description = "Azure Subscription ID where resources will be created"
  type        = string
  sensitive   = true
  # Example: "12345678-1234-1234-1234-123456789012"
}

variable "location" {
  description = "Azure region where resources will be deployed"
  type        = string
  default     = "East US"
  # Other options: "West US", "Europe West", "Southeast Asia", etc.
}

variable "ssh_public_key" {
  description = "SSH public key for VM access. If empty, a new key pair will be generated"
  type        = string
  default     = ""
  sensitive   = true
  # Example: "ssh-rsa AAAA..."
}

# ================================================================================
# IMPORTANT NOTES ABOUT AZURE CONFIGURATION
# ================================================================================
#
# Azure Subscription ID:
#   - Required to authenticate and identify the Azure subscription
#   - Find it with: az account show --query id
#   - Or in Azure Portal: Subscriptions → Select your subscription
#   - Mark as sensitive to prevent showing in logs
#
# Location (Azure Region):
#   - Must be a valid Azure region
#   - Common regions:
#     - East US (eastus)
#     - West US (westus)
#     - West Europe (westeurope)
#     - Southeast Asia (southeastasia)
#     - Central US (centralus)
#   - View all available regions: az account list-locations
#
# SSH Public Key:
#   - For production, use your managed SSH keys
#   - If not provided, Terraform will generate a new key pair
#   - Generated keys are stored in Terraform state (sensitive!)
#   - For testing only, not recommended for production
#
# Workspaces:
#   - terraform.workspace variable is automatically available
#   - "default" workspace is created automatically
#   - Create new workspaces with: terraform workspace new <name>
#   - Each workspace gets its own state file and variable values
#
# Cost Considerations:
#   - Standard_B1s: ~$10/month (development)
#   - Standard_B2s: ~$50/month (production)
#   - Ensure you destroy unused workspaces to avoid charges!
