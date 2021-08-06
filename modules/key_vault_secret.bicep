@description('Enter the secret name.')
param secretName string

@description('Type of the secret')
param contentType string = 'text/plain'

@description('Value of the secret')
param contentValue string

@description('Name of the vault')
param keyVaultName string


resource key_vault 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: keyVaultName
}

resource secret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  parent: key_vault
  name: secretName
  properties: {
    contentType: contentType
    value: contentValue
  }
}
