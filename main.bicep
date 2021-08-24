param baseName string

@description('Username for the Virtual Machine.')
param adminUsername string

@description('Password for the Virtual Machine.')
@secure()
param adminPassword string = ''

@description('The base URI where artifacts required by this template are located. When the template is deployed using the accompanying scripts, a private location in the subscription will be used and this value will be automatically generated.')
param artifactsLocation string = ''

@description('The sasToken required to access _artifactsLocation.  When the template is deployed using the accompanying scripts, a sasToken will be automatically generated.')
@secure()
param artifactsLocationSasToken string = ''

@description('Location for all resources.')
param location string = 'uksouth'

@description('Default VM Size')
param vmSize string = 'Standard_B4ms'

param clientIp string
param keyVaultName string = '${baseName}-kv'
param resourceTags object = {}

param vmAdminPrincipalType string
param vmAdminObjectId string
param now string = utcNow()
param salt string = newGuid()


// This VM is intended to be only be accessed via AAD accounts, so the local
// administrator account password should not ordinarily be required
// If one hasn't been specified, generate a password that should reasonably difficult to predict
var vmPassword = empty(adminPassword) ? '${uniqueString(now, salt, resourceGroup.id)}!' : adminPassword
var vmPasswordSecretName = 'vmAdminPassword'

// Use a simple prefix-based naming convention for all the resources
var rgName = 'rg-${baseName}-workstation'
var nicName_var = '${baseName}-nic'
var addressPrefix = '10.0.0.0/16'
var subnetName = 'default'
var subnetPrefix = '10.0.0.0/24'
var vmName_var = '${baseName}-vm'
var virtualNetworkName_var = '${baseName}-vnet'
var publicIPAddressName_var = '${baseName}-pip'
var networkSecurityGroupName_var = '${baseName}-nsg'

var scriptFileName = 'bootstrap.ps1'
var scriptUris = array('https://raw.githubusercontent.com/endjin/endjin-workstation-setup/feature/choco/bootstrap/bootstrap.ps1')


targetScope = 'subscription'


resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgName
  location: location
  tags: resourceTags
}

// Creates a key vault and stores the VM admin password
module key_vault 'modules/key_vault.bicep' = {
  name: 'keyVaultDeploy'
  scope: resourceGroup
  params: {
    keyVaultName: keyVaultName
    location: location
    accessPolicies: []
    enabledForDeployment: true
    diagnosticsEnabled: false
    createDiagnosticsStorageAccount: false
    diagnosticsStorageAccountName: toLower('${baseName}kvdiags')
    enableSoftDelete: false
    tagValues: resourceTags
  }
}
module keyvault_secret 'modules/key_vault_secret.bicep' = {
  name: 'keyVaultSecretDeploy'
  scope: resourceGroup
  params: {
    keyVaultName: key_vault.outputs.name
    secretName: vmPasswordSecretName
    contentValue: string(vmPassword)
  }
}

// Setup the VM and it associated resources
module publicIp 'modules/public_ip.bicep' = {
  scope: resourceGroup
  name: 'publicIpDeploy'
  params: {
    name: publicIPAddressName_var
    allocationMethod: 'Static'
  }
}

module nsg 'modules/network_security_group.bicep' = {
  scope: resourceGroup
  name: 'nsgDeploy'
  params: {
    name: networkSecurityGroupName_var
    rules: [
      {
        name: 'default-allow-3389'
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '3389'
          protocol: 'Tcp'
          sourceAddressPrefix: clientIp
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

module vnet 'modules/virtual_network.bicep' = {
  scope: resourceGroup
  name: 'vnetDeploy'
  params: {
    name: virtualNetworkName_var
    addressPrefix: addressPrefix
    subnetName: subnetName
    subnetPrefix: subnetPrefix
    nsgResourceId: nsg.outputs.resourceId
  }
}

module nic 'modules/network_interface.bicep' = {
  scope: resourceGroup
  name: 'nicDeploy'
  params: {
    name: nicName_var
    publicIpResourceId: publicIp.outputs.resourceId
    subnetResourceId: vnet.outputs.subnetResourceId
  }
}

module vm 'modules/virtual_machine.bicep' = {
  scope: resourceGroup
  name: 'vmDeploy'
  params: {
    name: vmName_var
    adminUsername: adminUsername
    adminPassword: vmPassword
    imageReference: {
      publisher: 'MicrosoftWindowsDesktop'
      offer: 'office-365'
      sku: '21h1-evd-o365pp-g2'
      version: 'latest'
    }
    nicResourceId: nic.outputs.resourceId
    vmSize: vmSize
    runCustomScripts: true
    scriptUris: scriptUris
    scriptFileName: scriptFileName
    enableAadLogin: true
    assigneePrincipalType: vmAdminPrincipalType
    assigneeObjectId: vmAdminObjectId
  }
}
