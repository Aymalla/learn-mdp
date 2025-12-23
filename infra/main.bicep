// Main Bicep template for Managed DevOps Pool Infrastructure
targetScope = 'resourceGroup'

@minLength(1)
@maxLength(64)
@description('Name of the environment that can be used as part of naming resource convention')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

@description('The name of the Dev Center')
param devCenterName string = 'mdp-devcenter-${environmentName}'

@description('The name of the Dev Center Project')
param devCenterProjectName string = 'mdp-project-${environmentName}'

@description('The name of the Virtual Network')
param vnetName string = 'mdp-vnet-${environmentName}'

@description('The name of the Managed DevOps Pool')
param poolName string = 'mdp-pool-${environmentName}'

@description('The Azure DevOps organization name')
@minLength(1)
param organizationName string

@description('The Azure DevOps project names')
param projectNames array = []

@description('The virtual network address prefix')
param vnetAddressPrefix string = '10.0.0.0/16'

@description('The subnet address prefix')
param subnetAddressPrefix string = '10.0.0.0/24'

@description('The maximum number of concurrent agents')
@minValue(1)
param maximumConcurrency int = 1

@description('The VM size for pool agents')
param vmSize string = 'Standard_D2s_v3'

@description('The agent image to use')
param imageName string = 'ubuntu-22.04/latest'

var tags = {
  'azd-env-name': environmentName
  environment: environmentName
  managedBy: 'Bicep'
  purpose: 'ManagedDevOpsPool'
}

// Deploy Virtual Network
module vnet 'modules/vnet.bicep' = {
  name: 'vnet-deployment'
  params: {
    vnetName: vnetName
    location: location
    addressPrefix: vnetAddressPrefix
    subnetPrefix: subnetAddressPrefix
    tags: tags
  }
}

// Deploy Dev Center
module devCenter 'modules/devCenter.bicep' = {
  name: 'devcenter-deployment'
  params: {
    devCenterName: devCenterName
    location: location
    tags: tags
  }
}

// Deploy Dev Center Project
module devCenterProject 'modules/devCenterProject.bicep' = {
  name: 'devcenterproject-deployment'
  params: {
    projectName: devCenterProjectName
    location: location
    devCenterId: devCenter.outputs.devCenterId
    tags: tags
  }
}

// Deploy Managed DevOps Pool
module managedPool 'modules/managedPool.bicep' = {
  name: 'managedpool-deployment'
  params: {
    poolName: poolName
    location: location
    devCenterId: devCenterProject.outputs.projectId
    subnetId: vnet.outputs.subnetId
    organizationName: organizationName
    projectNames: projectNames
    maximumConcurrency: maximumConcurrency
    vmSize: vmSize
    imageName: imageName
    tags: tags
  }
}

// Outputs
output devCenterId string = devCenter.outputs.devCenterId
output devCenterName string = devCenter.outputs.devCenterName
output devCenterProjectId string = devCenterProject.outputs.projectId
output devCenterProjectName string = devCenterProject.outputs.projectName
output vnetId string = vnet.outputs.vnetId
output vnetName string = vnet.outputs.vnetName
output subnetId string = vnet.outputs.subnetId
output poolId string = managedPool.outputs.poolId
output poolName string = managedPool.outputs.poolName
