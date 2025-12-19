targetScope = 'resourceGroup'

@description('The location for all resources')
param location string = resourceGroup().location

@description('The name of the Managed DevOps Pool')
param poolName string

@description('The maximum number of agents in the pool')
@minValue(1)
@maxValue(100)
param maximumConcurrency int = 1

@description('The Azure DevOps organization name')
param devOpsOrganizationName string

@description('The Azure DevOps project names (comma-separated)')
param devOpsProjectNames string

@description('The SKU name for the Managed DevOps Pool')
@allowed([
  'Standard'
  'Basic'
])
param skuName string = 'Standard'

@description('Environment name')
param environmentName string

@description('The agent profile resource ID')
param agentProfile object = {
  kind: 'Stateless'
}

// Create the Managed DevOps Pool
resource managedDevOpsPool 'Microsoft.DevOpsInfrastructure/pools@2024-04-04-preview' = {
  name: poolName
  location: location
  properties: {
    organizationProfile: {
      kind: 'AzureDevOps'
      organizations: [
        {
          url: 'https://dev.azure.com/${devOpsOrganizationName}'
          projects: split(devOpsProjectNames, ',')
        }
      ]
    }
    agentProfile: agentProfile
    maximumConcurrency: maximumConcurrency
    devCenterProjectResourceId: ''
  }
  sku: {
    name: skuName
  }
  tags: {
    environment: environmentName
  }
}

output poolId string = managedDevOpsPool.id
output poolName string = managedDevOpsPool.name
output poolLocation string = managedDevOpsPool.location
