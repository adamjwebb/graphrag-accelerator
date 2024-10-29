// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

@description('Name of the NSG for the API Management service.')
param nsgName string = 'apim-nsg-${uniqueString(resourceGroup().id)}'

@description('Azure region where the resources will be deployed')
param location string = resourceGroup().location

param nsgSecurityRules array = []

resource nsg 'Microsoft.Network/networkSecurityGroups@2024-01-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: nsgSecurityRules
  }
}

output id string = nsg.id
