// Virtual Network module for Managed DevOps Pool
@description('The name of the virtual network')
param vnetName string

@description('The location for the virtual network')
param location string = resourceGroup().location

@description('The address prefix for the virtual network')
param addressPrefix string = '10.0.0.0/16'

@description('The subnet name')
param subnetName string = 'default'

@description('The subnet address prefix')
param subnetPrefix string = '10.0.0.0/24'

@description('Tags to apply to the virtual network')
param tags object = {}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetPrefix
          delegations: [
            {
              name: 'Microsoft.DevOpsInfrastructure/pools'
              properties: {
                serviceName: 'Microsoft.DevOpsInfrastructure/pools'
              }
            }
          ]
        }
      }
    ]
  }
}

output vnetId string = virtualNetwork.id
output subnetId string = virtualNetwork.properties.subnets[0].id
output vnetName string = virtualNetwork.name
