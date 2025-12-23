// Dev Center Project module for Managed DevOps Pool
@description('The name of the Dev Center Project')
param projectName string

@description('The location for the Dev Center Project')
param location string = resourceGroup().location

@description('The Dev Center resource ID')
param devCenterId string

@description('Tags to apply to the Dev Center Project')
param tags object = {}

resource devCenterProject 'Microsoft.DevCenter/projects@2023-04-01' = {
  name: projectName
  location: location
  tags: tags
  properties: {
    devCenterId: devCenterId
  }
}

output projectId string = devCenterProject.id
output projectName string = devCenterProject.name
