param name string
param nsgResourceId string
param addressPrefix string
param subnetName string
param subnetPrefix string

param location string = resourceGroup().location

resource virtualNetworkName 'Microsoft.Network/virtualNetworks@2020-08-01' = {
  name: name
  location: location
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
          networkSecurityGroup: {
            id: nsgResourceId
          }
        }
      }
    ]
  }
}

output subnetResourceId string = virtualNetworkName.properties.subnets[0].id
