param name string
param adminUsername string
@secure()
param adminPassword string
param vmSize string
param imageReference object
param nicResourceId string
param runCustomScripts bool
param scriptUris array
param scriptFileName string

param assigneePrincipalType string
param assigneeObjectId string
@allowed([
  'Virtual Machine Administrator Login'
  'Virtual Machine User Login'
])
param assigneeRoleName string = 'Virtual Machine Administrator Login'

param location string = resourceGroup().location
param enableAadLogin bool = true


var roleDefinitionIds = {
  'Virtual Machine Administrator Login': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '1c0163c0-47e6-4577-8991-ea5c82e286e4')
  'Virtual Machine User Login': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'fb879df8-f326-4884-b1cf-06f3ad86be52')
}
var roleAssignmentId = guid(roleDefinitionIds[assigneeRoleName], assigneeObjectId, vm.id)


resource vm 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: name
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: imageReference
      osDisk: {
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nicResourceId
        }
      ]
    }
  }
}

resource customScriptExtension 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = if (runCustomScripts) {
  parent: vm
  name: 'CustomScriptExtension'
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: scriptUris
      commandToExecute: 'powershell -ExecutionPolicy Unrestricted -File ${scriptFileName}'
    }
  }
}

resource anti_malware 'Microsoft.Compute/virtualMachines/extensions@2021-03-01' = {
  parent: vm
  name: 'msAntiMalware'
  location: location
  properties: {
    autoUpgradeMinorVersion: true
    publisher: 'Microsoft.Azure.Security'
    type: 'IaaSAntimalware'
    typeHandlerVersion: '1.3'
    settings: {
      AntimalwareEnabled: true
      Exclusions: {
        Paths: ''
        Extensions: ''
        Processes: ''
      }
      RealtimeProtectionEnabled: true
      ScheduledScanSettings: {
        isEnabled: true
        scanType: 'Quick'
        day: 7
        time: 120
      }
    }
    protectedSettings: null
  }
}

resource auto_shutdown 'Microsoft.DevTestLab/schedules@2018-09-15' = {
  name: 'shutdown-computevm-${vm.name}'
  location: location
  properties: {
    status: 'Enabled'
    taskType: 'ComputeVmShutdownTask'
    dailyRecurrence: {
      time: '1830'
    }
    timeZoneId: 'GMT Standard Time'
    targetResourceId: vm.id
    notificationSettings: {
      status: 'Disabled'
      notificationLocale: 'en'
      timeInMinutes: 30
      emailRecipient: ''
    }
  }
}

resource aad_login 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = if (enableAadLogin) {
  parent: vm
  name: 'AADLoginForWindows'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.ActiveDirectory'
    type: 'AADLoginForWindows'
    typeHandlerVersion: '0.4'
    autoUpgradeMinorVersion: true
  }
}

// If using AzureAD authentication grant the required role assignment
resource role_assignment 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = if (enableAadLogin) {
  name: roleAssignmentId
  scope: vm
  properties: {
    roleDefinitionId: roleDefinitionIds[assigneeRoleName]
    principalId: assigneeObjectId
    principalType: assigneePrincipalType
  }
}


output resourceId string = vm.id
