# endjin-workstation-setup

This repository helps you setup a Azure virtual machine that you can use a workstation. It also serves as an introduction to working with infrastructure in the Azure cloud.

The intention is that you fork this repo into your own GitHub account and customise the virtual machine as required.

## Overview
The repo contains a set of [Bicep](https://github.com/Azure/bicep/blob/main/README.md) templates that do the following:

* Create a Windows 10 virtual machine with the Office 365 apps installed
* Enables RDP access for the public IP of the user running this scripts
* Enables an auto-shutdown policy to help manage costs (the VM will automatically shutdown as 18:30 each day)
* Installs the Microsoft Anti-Malware software

## Pre-Requisites

1. Access to an Azure subscription (it is suggested that you use your Visual Studio or 'MPN' subscription for this)
1. PowerShell Core installed:
    * Windows: https://github.com/PowerShell/PowerShell/releases/download/v7.1.3/PowerShell-7.1.3-win-x64.msi
1. [PowerShell Az](https://www.powershellgallery.com/packages/Az/5.9.0) module installed:
    * `Install-Module -Name Az -RequiredVersion 5.9.0 -Scope CurrentUser -AllowClobber`
1. Logged-in to the above module:
    * `Connect-AzAccount`
1. Connected to the correct subscription:
    * `Set-AzContext -SubscriptionId <mpn-subscription-id>`

## Usage

Run the `deploy.ps1` script, which take the following parameters:

* BaseName - a naming prefix that will be used when creating the various Azure resources
* AdminPassword - the password used to login the VM

For example:
```
./deploy.ps1 -BaseName "<your-initials>wrkstn"
```

You will then be prompted to enter a password which will be masked as you type - ensure you keep a note of this in a password manager.

Next you will be asked to confirm that the displayed Azure subscription details are correct (i.e. you are connected to the correct subscription) and then the automation will run through.

Once this has finished, connect to the [Azure Portal](https://portal.azure.com) and you should be able to find a new resource group in your subscription with the name:
* `rg-<basename>-workstation`