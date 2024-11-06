@description('The name of the Container Registry resource. Will be automatically generated if not provided.')
param registryName string

@description('The location of the Container Registry resource.')
param location string = resourceGroup().location

@allowed(['Enabled', 'Disabled'])
param publicNetworkAccess string = 'Disabled'

@description('Array of objects with fields principalId, principalType, roleDefinitionId')
param roleAssignments array = []

resource registry 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' = {
  name: registryName
  location: location
  sku: {
    name: publicNetworkAccess == 'Disabled' ? 'Premium' : 'Standard'
  }
  properties: {
    adminUserEnabled: false
    encryption: {
      status: 'disabled'
    }
    dataEndpointEnabled: false
    publicNetworkAccess: publicNetworkAccess
    networkRuleBypassOptions: 'AzureServices'
    zoneRedundancy: 'Disabled'
    anonymousPullEnabled: false
    metadataSearch: 'Disabled'
  }
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for role in roleAssignments: {
    name: guid('${role.principalId}-${role.principalType}-${role.roleDefinitionId}')
    scope: registry
    properties: role
  }
]

resource acrTask 'Microsoft.ContainerRegistry/registries/tasks@2019-06-01-preview' = {
  name: 'graphrag-build-task'
  parent: registry
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    status: 'Disabled'
    platform: {
      os: 'Linux'
    }
    step: {
      type: 'Docker'
      contextPath: 'https://github.com/adamjwebb/graphrag-accelerator.git#existing-vnet-no-public-endpoints'
      dockerFilePath: './docker/Dockerfile-backend'
      imageNames: [
        '${registry.name}/graphrag:backend'
      ]
    }
  }
}

/*  resource acrTaskRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: '5775b2f4-3b8e-408b-9f6a-f789226fae03'
  scope: registry
  properties: {
    principalId: 'b1dddbe2-6c3c-4110-8797-71a60d46c39d'
    principalType: 'ServicePrincipal'
    roleDefinitionId: '8311e382-0749-4cb8-b61a-304f252e45ec'
  }
}  */

output name string = registry.name
output id string = registry.id
output loginServer string = registry.properties.loginServer
