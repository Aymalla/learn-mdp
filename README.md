# MDP - Azure Managed DevOps Pools Stuck Cases Replication

This repository provides infrastructure‑as‑code (IaC) to deploy an Azure Managed DevOps Pools (MDP) environment and integrate a GitHub repository’s Actions workflows with it.
The setup is used to reproduce issues where MDP is not behaving as expected, and is intended specifically for troubleshooting and testing.

### Issues Being Replicated
- Agents remain stuck in the “Allocated” state
- the jobs getting stuck in "Queued" State

### Prerequisites

- An Azure subscription
- Azure Managed DevOps Pools subscription prerequisites (see [Azure Managed DevOps Pools documentation](https://learn.microsoft.com/en-us/azure/devops/managed-devops-pools/prerequisites?view=azure-devops&tabs=azure-portal))
- GitHub organization with `Managed DevOps Pools application` installed
- Fork of this repository in your GitHub organization

#### Tools

- Azure Developer CLI (azd)
- GitHub CLI (gh)
- DevContainer (Has all necessary tools pre-installed)

## Getting Started

### Clone the Repository

```bash
git clone https://github.com/<your-org>/<your-repo>.git
cd <your-repo>
```

### Initialize DevContainer

Open the repository in a DevContainer to ensure all required tools are available.

### Infrastructure Deployment

The infrastructure setup includes:

- **Dev Center**: Azure Dev Center for managing development infrastructure
- **Dev Center Project**: Project configuration within the Dev Center
- **Virtual Network**: Dedicated VNet with subnet delegation for managed pools
- **Managed DevOps Pool**: Scalable pool of build agents for CI/CD pipelines

```bash
# Azure Login
az login

# Initialize azd (first time only)
azd init

# GH CLI Authentication
gh auth login

# Set required environment variables
azd env set AZURE_LOCATION "swedencentral"
azd env set AZURE_ENV_NAME "<unique-env-name>"
azd env set GITHUB_ORG_URL "<your-org-url>"
azd env set GITHUB_REPOSITORY_NAME "<your-repo-name>"

principal_id=$(az ad sp list --display-name 'DevOpsInfrastructure' --query '[0].id' -o tsv)
azd env set DEVOPSINFRASTRUCTURE_PRINCIPLE_ID "$principal_id"

# Provision and deploy infrastructure
azd up
```

### Reproducing the Agent Stuck in "Allocated" State

This issue occurs when MDP agents get stuck in the “Allocated” state during high workloads, which leads to pool saturation and makes agents unavailable for new jobs. To reproduce this behavior, run the following command to trigger high volume of workflow runs that use the MDP self‑hosted runners:

```bash
make reproduce-agent-stuck
```

- **How it works:** This command triggers two batches of 100 workflow runs each, running concurrently to simulate high load on the MDP pool.
- **Suspected Cause:** High concurrency levels in MDP workflow runs, specifically related to resource allocation and cleanup.
- **Results**: After each batch completes, check the workflow runs in your GitHub repository. You should see that all the workflow runs are completed and some agents are stuck in the “Allocated” state. if you did not observe the issue, rerun the command to trigger more workflow runs.
- **Used Workflow:** The workflow used to reproduce this issue is defined in [`.github/workflows/mdp-test.yml`](.github/workflows/mdp-test.yml).

### Reproducing the Job Stuck in "Queued" State

This issue occurs when jobs remain stuck in the “Queued and waiting for agent to pick it up” state, causing them to never progress. To reproduce this behavior, run the following command to trigger multiple workflow runs that use the MDP self‑hosted runners:

```bash
make reproduce-job-stuck
```

- **How it works:** This command triggers a batch of 2 workflow runs that attempt to use the MDP self-hosted runners and are in the same concurrency group.
- **Suspected Cause:** Something related to the workflow concurrency group and MDP agent assignment.
- **Results**: After the batch completes, check the workflow runs in your GitHub repository. You should see that one run has been canceled while the other is stuck in the queued state. If you do not observe the issue, rerun the command to trigger additional workflow runs.
- **Used Workflow:** The workflow used to reproduce this issue is defined in [`.github/workflows/mdp-test-job-stuck.yml`](.github/workflows/mdp-test-job-stuck.yml).

## Deployment Customization

Change the parameters in `main.parameters.json` to specify the desired Azure region for deployment, Image, and VM size.

- **Supported Azure Regions:** Available regions for resource type 'Microsoft.DevCenter/devcenters': [`australiaeast`, `brazilsouth`, `canadacentral`, `centralus`, `francecentral`, `polandcentral`, `spaincentral`, `uaenorth`, `westeurope`, `germanywestcentral`, `italynorth`, `japaneast`, `japanwest`, `uksouth`, `eastus`, `eastus2`, `southafricanorth`, `southcentralus`, `southeastasia`, `switzerlandnorth`, `swedencentral`, `westus2`, `westus3`, `centralindia`, `eastasia`, `northeurope`, `koreacentral`], default is `swedencentral`.
- **Supported images:** [`windows-2019`, `windows-2022`, `windows-2025`, `ubuntu-20.04`, `ubuntu-22.04`, `ubuntu-24.04`], default is `ubuntu-24.04`.
- **VM Size:** based on the available quota in your subscription for MDP (the default is `Standard_D4ads_v5`).
- **Network Configuration**: To use a custom VNet address space, modify these parameters: `vnetAddressPrefix`: Virtual network CIDR (default: 10.0.0.0/16), `subnetAddressPrefix`: Subnet CIDR (default: 10.0.0.0/24)

## Documentation

- [Azure Managed DevOps Pools](https://learn.microsoft.com/en-us/azure/devops/managed-devops-pools/overview?view=azure-devops)
- [Azure MDP Deployment using Bicep Modules](https://github.com/Azure/bicep-registry-modules/tree/main/avm/res/dev-ops-infrastructure/pool)
- Azure Portal link to access the in-preview features of Azure MDP (GitHub integration): [Azure Portal MDP](https://aka.ms/mdp-github)

## License

See [LICENSE](./LICENSE) file for details.
