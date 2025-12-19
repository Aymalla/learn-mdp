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

- Azure CLI
- An Azure subscription
- Azure DevOps organization (optional)

### Deploy

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
```

## Documentation

- [Infrastructure Deployment Guide](./infra/README.md)
- [Azure Managed DevOps Pools](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/pools-queues)

## License

See [LICENSE](./LICENSE) file for details.
