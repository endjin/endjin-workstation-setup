param name string
param rules array

param location string = resourceGroup().location

resource nsg 'Microsoft.Network/networkSecurityGroups@2020-08-01' = {
  name: name
  location: location
  properties: {
    securityRules: rules
  }
}

output resourceId string = nsg.id
