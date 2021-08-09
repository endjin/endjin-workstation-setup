[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string] $BaseName,

    [switch] $DryRun
)
$ErrorActionPreference = "Stop"
$InformationPreference = "Continue"
Set-StrictMode -Version 4.0

$here = Split-Path -Parent $PSCommandPath

Get-AzContext | Format-List | Out-String | Write-Information
Read-Host "Are the above connection details correct? - <RETURN> to continue, <CTRL-C> to cancel"

# Helper to generate a strong random password
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

# Lookup the AAD ObjectId for the identity running this script
# This will be used to grant access to the VM
$azureAccount = (Get-AzContext).Account
$identityObjectId = ($azureAccount -eq "ServicePrincipal") ? `
                        (Get-AzAdServicePrincipal -ApplicationId $azureAccount).Id : 
                        (Get-AzAdUser -UserPrincipalName $azureAccount).Id

# Setup the parameters needed by the Bicep/ARM template
$templateParameters = @{
    baseName = $BaseName
    adminUsername = "endjin-admin"
    adminPassword = _generatePassword
    vmSize = "Standard_B4ms"
    location = "uksouth"
    clientIp = (Invoke-RestMethod -UserAgent curl -Uri https://ifconfig.io).Trim()
    vmAdminPrincipalType = $azureAccount.Type
    vmAdminObjectId = $identityObjectId
}

Write-Information "Deploying ARM template... [IsDryRun: $DryRun]"
$deployName = "workstation-{0}" -f ((Get-Date).ToUniversalTime()).ToString('MMdd-HHmm')
$res = New-AzDeployment -Name $deployName `
                            -TemplateFile (Join-Path $here "main.bicep") `
                            -WhatIf:$DryRun `
                            -WhatIfResultFormat FullResourcePayloads `
                            @templateParameters `
                            -Verbose

Write-Information ("`n{0} (objectId={1}) has been granted Admin login rights to the VM`n" -f $azureAccount.Id, $identityObjectId)
