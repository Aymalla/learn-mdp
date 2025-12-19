# Managed DevOps Pool Infrastructure

This directory contains the Infrastructure as Code (IaC) using Azure Bicep to deploy a complete Managed DevOps Pool solution with Dev Center, Virtual Network, and Managed Pool resources.

## Architecture

The infrastructure consists of three main components:

1. **Dev Center**: The Azure Dev Center that manages the development infrastructure
2. **Virtual Network (VNet)**: A dedicated VNet with a subnet delegated to Microsoft.DevOpsInfrastructure/pools
3. **Managed DevOps Pool**: The managed pool that provides Azure Pipelines runners for Azure DevOps

## Prerequisites

**Option 1: Azure Developer CLI (Recommended)**
- Azure Developer CLI ([Install azd](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/install-azd))
- An Azure subscription with appropriate permissions
- An Azure DevOps organization (if using Azure DevOps)

**Option 2: Azure CLI**
- Azure CLI installed ([Install Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli))
- Bicep CLI installed (comes with Azure CLI 2.20.0+)
- An Azure subscription with appropriate permissions
- An Azure DevOps organization (if using Azure DevOps)

## File Structure

```
infra/
├── main.bicep                      # Main orchestration file
├── main.parameters.json            # Parameters file (Azure CLI)
├── main.parameters.azd.json        # Parameters file (Azure Developer CLI)
├── modules/
│   ├── devCenter.bicep            # Dev Center module
│   ├── vnet.bicep                 # Virtual Network module
│   └── managedPool.bicep          # Managed DevOps Pool module
└── README.md                       # This file
```

## Deployment

### Option 1: Deploy with Azure Developer CLI (Recommended)

The Azure Developer CLI (azd) provides a streamlined deployment experience with environment management.

#### 1. Initialize azd (first time only)

```bash
azd init
```

#### 2. Configure Environment Variables

Set the required Azure DevOps organization name:

```bash
azd env set AZURE_DEVOPS_ORG_NAME "your-org-name"
```

Optional configuration:

```bash
# Set maximum concurrent agents (default: 1)
azd env set MAXIMUM_CONCURRENCY 2

# Set VM size (default: Standard_D2s_v3)
azd env set VM_SIZE "Standard_D4s_v3"

# Set agent image (default: ubuntu-22.04/latest)
azd env set IMAGE_NAME "windows-2022/latest"
```

**Note**: To configure specific Azure DevOps projects (instead of all projects), edit `infra/main.parameters.azd.json` and set the `projectNames` array:
```json
"projectNames": {
  "value": ["project1", "project2"]
}
```

#### 3. Provision and Deploy

```bash
azd up
```

This single command will:
- Create the resource group
- Deploy all infrastructure components
- Store deployment outputs

#### 4. View Deployment

```bash
# Show environment details
azd env get-values

# Show deployment outputs
azd show
```

#### 5. Clean Up

```bash
azd down
```

### Option 2: Deploy with Azure CLI

#### 1. Login to Azure

```bash
az login
az account set --subscription <subscription-id>
```

#### 2. Create Resource Group

```bash
az group create \
  --name rg-managed-devops-pool \
  --location eastus
```

#### 3. Configure Parameters

Update `main.parameters.json` with your specific values:

```json
{
  "parameters": {
    "environmentName": { "value": "dev" },
    "location": { "value": "eastus" },
    "organizationName": { "value": "your-org-name" }
  }
}
```

#### 4. Validate the Bicep Template

```bash
az deployment group validate \
  --resource-group rg-managed-devops-pool \
  --template-file infra/main.bicep \
  --parameters infra/main.parameters.json
```

#### 5. Deploy the Infrastructure

```bash
az deployment group create \
  --resource-group rg-managed-devops-pool \
  --template-file infra/main.bicep \
  --parameters infra/main.parameters.json \
  --name mdp-deployment
```

#### 6. Verify Deployment

```bash
az deployment group show \
  --resource-group rg-managed-devops-pool \
  --name mdp-deployment \
  --query properties.outputs
```

## What-If Analysis

Before deploying, you can preview the changes:

```bash
az deployment group what-if \
  --resource-group rg-managed-devops-pool \
  --template-file infra/main.bicep \
  --parameters infra/main.parameters.json
```

## Outputs

The deployment provides the following outputs:

- **devCenterId**: Resource ID of the Dev Center
- **devCenterName**: Name of the Dev Center
- **vnetId**: Resource ID of the Virtual Network
- **vnetName**: Name of the Virtual Network
- **subnetId**: Resource ID of the subnet
- **poolId**: Resource ID of the Managed DevOps Pool
- **poolName**: Name of the Managed DevOps Pool

## Customization

### Changing VM Size

Modify the `vmSize` parameter in `main.parameters.json`. Common sizes:
- `Standard_D2s_v3` (2 vCPUs, 8 GB RAM)
- `Standard_D4s_v3` (4 vCPUs, 16 GB RAM)
- `Standard_D8s_v3` (8 vCPUs, 32 GB RAM)

### Changing Agent Image

Supported images:
- `ubuntu-22.04/latest`
- `ubuntu-20.04/latest`
- `windows-2022/latest`
- `windows-2019/latest`

### Network Configuration

To use a custom VNet address space, modify these parameters:
- `vnetAddressPrefix`: Virtual network CIDR (default: 10.0.0.0/16)
- `subnetAddressPrefix`: Subnet CIDR (default: 10.0.0.0/24)

## Clean Up

To delete all resources:

```bash
az group delete \
  --name rg-managed-devops-pool \
  --yes --no-wait
```

## Resources

- [Azure Managed DevOps Pools Documentation](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/pools-queues)
- [Azure Bicep Documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- [Azure Dev Center Documentation](https://learn.microsoft.com/en-us/azure/dev-center/)

## Troubleshooting

### Common Issues

1. **Subnet delegation error**: Ensure the subnet is delegated to `Microsoft.DevOpsInfrastructure/pools`
2. **Resource provider not registered**: Run `az provider register --namespace Microsoft.DevOpsInfrastructure`
3. **Permission issues**: Ensure you have Contributor role on the subscription or resource group

### Enable Debug Logging

```bash
az deployment group create \
  --resource-group rg-managed-devops-pool \
  --template-file infra/main.bicep \
  --parameters infra/main.parameters.json \
  --debug
```

## Contributing

When making changes to the infrastructure:

1. Test changes using `az deployment group validate`
2. Use `az deployment group what-if` to preview changes
3. Update documentation if adding new parameters or resources
4. Follow Bicep best practices and linting rules
