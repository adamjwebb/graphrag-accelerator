@description('Name of the route table')
param routeTableName string

@description('The location of the Route Table.')
param location string = resourceGroup().location

@description('Array containing routes. For properties format refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.network/routetables?tabs=bicep#routepropertiesformat')
param routes array = []

resource routeTable 'Microsoft.Network/routeTables@2024-03-01' = {
  name: routeTableName
  location: location
  properties: {
    disableBgpRoutePropagation: true
    routes: [for route in routes: {
      name: route.name
      properties: {
        addressPrefix: route.addressPrefix
        hasBgpOverride: contains(route, 'hasBgpOverride') ? route.hasBgpOverride : null
        nextHopIpAddress: contains(route, 'nextHopIpAddress') ? route.nextHopIpAddress : null
        nextHopType: route.nextHopType
      }
    }]
  }
}

output routeTableId string = routeTable.id
