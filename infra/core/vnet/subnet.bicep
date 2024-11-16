param subnetName string
param virtualNetworkName string
param addressPrefix string
param nsgId string
param routeTable object = {}
param delegations array = []
param privateEndpointNetworkPolicies string = ''
param serviceEndpoints array = []

resource vnet 'Microsoft.Network/virtualNetworks@2024-01-01' existing = {
  name: virtualNetworkName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-11-01' = {
  parent: vnet
  name: subnetName
  properties: {
    addressPrefix: addressPrefix
    networkSecurityGroup: !empty(nsgId) ? {
      id: nsgId
    } : null
    delegations: delegations
    privateEndpointNetworkPolicies: privateEndpointNetworkPolicies
    serviceEndpoints: serviceEndpoints
    routeTable: empty(routeTable) ? null : routeTable
  }
}

output id string = subnet.id
