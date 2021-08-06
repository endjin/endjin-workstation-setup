@description('Tenant ID for the subscription and use assigned access to the vault.')
param tenantId string = subscription().tenantId

@description('Name of the vault')
param keyVaultName string

param location string

@allowed([
  'standard'
  'premium'
])
@description('SKU for the vault')
param keyVaultSku string = 'standard'

@description('Access policies for the vault.')
param accessPolicies array = []

@description('When true, the diagnostics storage account will be created')
param createDiagnosticsStorageAccount bool = true

@description('The storage account to use for diagnostics')
param diagnosticsStorageAccountName string = ''

@description('The number of day to retain logs for')
param diagnosticsRetentionDays int = 30

@description('Flag indicating whether diagnostics are enabled or not')
param diagnosticsEnabled bool = true

param enableRbacAuthorization bool = false
param enabledForDeployment bool = false
param enabledForDiskEncryption bool = false
param enabledForTemplateDeployment bool = false
param enableSoftDelete bool = true

@minValue(7)
@maxValue(90)
param softDeleteRetentionInDays int = 7

param tagValues object = {}

var keyVaultLocalTags = {
  displayName: 'KeyVault'
}

resource diagnosticsStorage 'Microsoft.Storage/storageAccounts@2021-02-01' = if (diagnosticsEnabled && createDiagnosticsStorageAccount) {
  name: diagnosticsStorageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    isHnsEnabled: false
    supportsHttpsTrafficOnly: true
  }
}

resource key_vault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: keyVaultName
  location: location
  tags: union(tagValues, keyVaultLocalTags)
  properties: {
    tenantId: tenantId
    accessPolicies: accessPolicies
    sku: {
      name: keyVaultSku
      family: 'A'
    }
    enabledForDeployment: enabledForDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    enabledForTemplateDeployment: enabledForTemplateDeployment
    enableRbacAuthorization: enableRbacAuthorization
    enableSoftDelete: enableSoftDelete
    softDeleteRetentionInDays: softDeleteRetentionInDays
  }
}

resource diagnostic_settings 'microsoft.insights/diagnosticSettings@2016-09-01' = if (diagnosticsEnabled) {
  name: 'service'
  location: location
  scope: key_vault
  properties: {
    storageAccountId: diagnosticsStorage.id
    logs: [
      {
        category: 'AuditEvent'
        enabled: diagnosticsEnabled
        retentionPolicy: {
          days: diagnosticsRetentionDays
          enabled: true
        }
      }
    ]
  }
  dependsOn: [
    key_vault
    diagnosticsStorage
  ]
}

output resourceId string = key_vault.id
output name string = key_vault.name
