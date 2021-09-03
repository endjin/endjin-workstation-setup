param name string

param location string = resourceGroup().location
param allocationMethod string = 'Dynamic'

resource publicIPAddressName 'Microsoft.Network/publicIPAddresses@2020-08-01' = {
  name: name
  location: location
  properties: {
    publicIPAllocationMethod: allocationMethod
  }
}

output resourceId string = publicIPAddressName.id
