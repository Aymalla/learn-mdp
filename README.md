# learn-mdp
Repository for GitHub Actions self-hosted runners using Azure Managed Devops Pools

## Prerequisites

- [Azure Developer CLI (azd)](https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd)
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli)
- An Azure subscription
- An Azure DevOps organization

## Infrastructure Provisioning

This repository uses Azure Developer CLI (azd) and Make to manage infrastructure provisioning.

### Setup

1. Copy the example environment file and configure it:

```bash
cp .env.example .env
# Edit .env with your values
```

2. Set the required environment variables (or source from .env):

```bash
export AZURE_ENV_NAME="dev"                                    # Environment name (e.g., dev, prod)
export AZURE_DEVOPS_ORG_NAME="your-org-name"                  # Azure DevOps organization name
export AZURE_DEVOPS_PROJECT_NAMES="project1,project2"         # Comma-separated project names
```

3. Optional environment variables:

```bash
export AZURE_MDP_POOL_NAME="mdp-pool"                         # Managed DevOps Pool name (default: mdp-pool)
export AZURE_MDP_MAX_CONCURRENCY="1"                          # Maximum concurrency (default: 1)
export AZURE_MDP_SKU="Standard"                               # SKU name (default: Standard)
export AZURE_LOCATION="eastus"                                # Azure region (optional)
export AZURE_SUBSCRIPTION_ID="your-subscription-id"           # Azure subscription ID (optional)
```

### Usage

View available commands:
```bash
make help
```

Check environment variables:
```bash
make env-check
```

Provision infrastructure:
```bash
make provision
```

Check deployment status:
```bash
make status
```

Destroy infrastructure:
```bash
make destroy
```

Clean local state:
```bash
make clean
```

## Direct AZD Commands

You can also use Azure Developer CLI directly:

```bash
# Initialize environment (first time only)
azd init

# Login to Azure
azd auth login

# Provision infrastructure
azd provision

# Check environment values
azd env get-values

# Destroy infrastructure
azd down
```

## Project Structure

```
.
├── azure.yaml                      # Azure Developer CLI configuration
├── infra/                          # Infrastructure as Code
│   ├── main.bicep                 # Main Bicep template
│   └── main.parameters.json       # Parameters file
├── Makefile                       # Infrastructure management commands
├── .env.example                   # Example environment variables file
└── README.md                      # This file
```

