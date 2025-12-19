# learn-mdp

Repository for GitHub Actions self-hosted runners using Azure Managed DevOps Pools

## Overview

This repository contains Infrastructure as Code (IaC) using Azure Bicep to deploy and manage Azure Managed DevOps Pools for GitHub Actions and Azure Pipelines.

## What's Included

The infrastructure setup includes:

- **Dev Center**: Azure Dev Center for managing development infrastructure
- **Virtual Network**: Dedicated VNet with subnet delegation for managed pools
- **Managed DevOps Pool**: Scalable pool of build agents for CI/CD pipelines

## Quick Start

See the [infrastructure documentation](./infra/README.md) for detailed deployment instructions.

### Prerequisites

- [Azure Developer CLI (azd)](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/install-azd) (recommended) or Azure CLI
- An Azure subscription
- Azure DevOps organization (optional)

### Deploy with Azure Developer CLI (Recommended)

```bash
# Initialize azd (first time only)
azd init

# Set required environment variables
azd env set AZURE_DEVOPS_ORG_NAME "your-org-name"

# Provision and deploy infrastructure
azd up

# Or use the Makefile
make azd-up
```

### Deploy with Azure CLI

```bash
# Login to Azure
az login

# Create resource group
az group create --name rg-managed-devops-pool --location eastus

# Deploy infrastructure
az deployment group create \
  --resource-group rg-managed-devops-pool \
  --template-file infra/main.bicep \
  --parameters infra/main.parameters.json

# Or use the Makefile
make deploy
```

### Using the Makefile

A Makefile is provided for common operations:

```bash
# Show all available commands
make help

# Validate Bicep templates
make validate

# Build Bicep templates
make build

# Deploy with Azure CLI
make deploy

# Deploy with Azure Developer CLI
make azd-up

# Clean generated files
make clean
```

## Documentation

- [Infrastructure Deployment Guide](./infra/README.md)
- [Azure Managed DevOps Pools](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/pools-queues)
- [Azure Developer CLI](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/)

## License

See [LICENSE](./LICENSE) file for details.
