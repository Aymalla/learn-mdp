// Managed DevOps Pool module
@description('The name of the Managed DevOps Pool')
param poolName string

@description('The location for the Managed DevOps Pool')
param location string = resourceGroup().location

@description('The Dev Center resource ID')
param devCenterId string

@description('The subnet resource ID for the pool')
param subnetId string

@description('The maximum number of agents in the pool')
@minValue(1)
param maximumConcurrency int = 1

@description('The Azure DevOps organization name')
@minLength(1)
param organizationName string

@description('The Azure DevOps project names. When left empty (default), the pool is available to all projects in the organization.')
param projectNames array = []

@description('The agent image to use')
param imageName string = 'ubuntu-22.04/latest'

@description('The VM size for the agents')
param vmSize string = 'Standard_D2s_v3'

@description('Tags to apply to the Managed DevOps Pool')
param tags object = {}

resource managedPool 'Microsoft.DevOpsInfrastructure/pools@2024-04-04-preview' = {
  name: poolName
  location: location
  tags: tags
  properties: {
    devCenterProjectResourceId: devCenterId
    maximumConcurrency: maximumConcurrency
    organizationProfile: {
      kind: 'AzureDevOps'
      organizations: [
        {
          url: 'https://dev.azure.com/${organizationName}'
          projects: projectNames
        }
      ]
    }
    agentProfile: {
      kind: 'Stateless'
      // For stateless agents, resource predictions are not required.
      // The schema requires this property, so it is intentionally left as an empty object.
      resourcePredictions: {}
    }
    fabricProfile: {
      kind: 'Vmss'
      sku: {
        name: vmSize
      }
      images: [
        {
          resourceId: imageName
        }
      ]
      networkProfile: {
        subnetId: subnetId
      }
    }
  }
}

output poolId string = managedPool.id
output poolName string = managedPool.name
