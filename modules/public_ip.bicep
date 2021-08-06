param name string

param location string = resourceGroup().location
param allocationMethod string = 'Dynamic'
// param dnsLabel string = ''

resource publicIPAddressName 'Microsoft.Network/publicIPAddresses@2020-08-01' = {
  name: name
  location: location
  properties: {
    publicIPAllocationMethod: allocationMethod
    // dnsSettings: {
    //   domainNameLabel: dnsLabel
    // }
  }
}

output resourceId string = publicIPAddressName.id
// output fqdn string = publicIPAddressName.properties.dnsSettings.fqdn
