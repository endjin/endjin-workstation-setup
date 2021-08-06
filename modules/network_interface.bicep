param name string
param publicIpResourceId string
param subnetResourceId string

param location string = resourceGroup().location

resource nic 'Microsoft.Network/networkInterfaces@2020-08-01' = {
  name: name
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIpResourceId
          }
          subnet: {
            id: subnetResourceId
          }
        }
      }
    ]
  }
}

output resourceId string = nic.id
