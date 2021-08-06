[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [securestring] $BaseName,

    [Parameter(Mandatory=$true)]
    [securestring] $AdminPassword,

    [switch] $DryRun
)
$ErrorActionPreference = "Stop"
$InformationPreference = "Continue"
Set-StrictMode -Version 4.0

$here = Split-Path -Parent $PSCommandPath

#region Helper functions
function _generatePassword {
    param(
        [Parameter(Mandatory = $false)]
        [ValidateRange(12, 256)]
        [int] $length = 14
    )
    # reference: https://gist.github.com/onlyann/00d9bb09d4b1338ffc88a213509a6caf
    $symbols = '!@#$%^&*'.ToCharArray()
    $characterList = 'a'..'z' + 'A'..'Z' + '0'..'9' + $symbols
    
    $iterations = 0
    do {
        $password = ""
        for ($i = 0; $i -lt $length; $i++) {
            $randomIndex = [System.Security.Cryptography.RandomNumberGenerator]::GetInt32(0, $characterList.Length)
            $password += $characterList[$randomIndex]
        }

        [int]$hasLowerChar = $password -cmatch '[a-z]'
        [int]$hasUpperChar = $password -cmatch '[A-Z]'
        [int]$hasDigit = $password -match '[0-9]'
        [int]$hasSymbol = $password.IndexOfAny($symbols) -ne -1

        $iterations++
    }
    until (($hasLowerChar + $hasUpperChar + $hasDigit + $hasSymbol) -eq 4)
    
    $password | ConvertTo-SecureString -AsPlainText
}
function _getPasswordFromKeyVaultOrGenerate {
    $password = $null
    $keyVault = Get-AzKeyVault -VaultName $deploymentConfig.KeyVaultName -ErrorAction SilentlyContinue
    if ($keyVault) {
        $existingSecret = Get-AzKeyVaultSecret -VaultName $keyVault.VaultName `
                                                -Name $deploymentConfig.AdministratorPasswordKeyVaultSecretName `
                                                -ErrorAction SilentlyContinue
    }
    if (!$keyVault -or !$existingSecret) {
        Write-Host "Generating new admin password"
        $password = _generatePassword -Length 12
    }
    else {
        $password = $existingSecret.SecretValue
    }

    return $password
}
function _generateKeyVaultAccessPolicy {
    # Prepare key-vault access policy parameter
    $accessPoliciesForARM = @()
    Write-Host "`nPreparing KeyVault access policy"
    foreach ($entry in $deploymentConfig.KeyVaultAccessPolicy) {
        if ( !$entry.ContainsKey("principalObjectId") -or !$entry.ContainsKey("permissions") ) {
            Write-Warning "Invalid KeyVaultAccessPolicy entry - must contain values for 'principalObjectId' and 'permisions' - skipping entry`n$($entry|Format-Table|out-string)"
            continue
        }
        
        # Check to see if objectId exists
        $response = Invoke-CorvusAzCliRestCommand -Uri "https://graph.microsoft.com/v1.0/directoryObjects/getByIds" `
                                                  -Method POST `
                                                  -Body @{ids = @($entry.principalObjectId)}
        if ($response.value) {
            Write-Host ("Ensuring KeyVault access for '{0}' (ObjectId={1})" -f $entry.description, $entry.principalObjectId)
            $accessPoliciesForARM += @{
                tenantId = (Get-AzContext).Tenant.Id
                objectId = $entry.principalObjectId
                permissions = @{
                    secrets = $entry.permissions["secrets"] ?? @()
                    keys = $entry.permissions["keys"] ?? @()
                    certificates = $entry.permissions["certificates"] ?? @()
                }
            }
        }
        else {
            Write-Warning "The AAD object with objectId '$($entry.principalObjectId)' could not be found - skipping"
            continue
        }
    }
    return $accessPoliciesForARM
}
#endregion

Get-AzContext | Format-List | Out-String | Write-Information
Read-Host "Are the above connection details correct? - <RETURN> to continue, <CTRL-C> to cancel"


# $keyVaultAccessPolicies = _generateKeyVaultAccessPolicy

$templateParameters = @{
    baseName = $BaseName
    adminUsername = "endjin"
    adminPassword = $AdminPassword
    vmSize = "Standard_B4ms"
    location = "uksouth"
    clientIp = (Invoke-RestMethod -UserAgent curl -Uri https://ifconfig.io).Trim()
    # keyVaultAccessPolicies = $keyVaultAccessPolicies
}

Write-Information "Deploying ARM template... [IsDryRun: $DryRun]"
$deployName = "workstation-{0}" -f ((Get-Date).ToUniversalTime()).ToString('MMdd-HHmm')
$res = New-AzDeployment -Name $deployName `
                            -TemplateFile (Join-Path $here "main.bicep") `
                            -WhatIf:$DryRun `
                            -WhatIfResultFormat FullResourcePayloads `
                            @templateParameters `
                            -Verbose

