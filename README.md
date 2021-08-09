# endjin-workstation-setup

This repository helps you setup a Azure virtual machine that you can use a workstation. It also serves as an introduction to working with infrastructure in the Azure cloud.

The intention is that you fork this repo into your own GitHub account and customise the virtual machine as required.

## Overview
The repo contains a set of [Bicep](https://github.com/Azure/bicep/blob/main/README.md) templates that do the following:

* Create a Windows 10 virtual machine with the Office 365 apps installed
* Enables RDP access for the public IP of the user running this scripts
* Enables an auto-shutdown policy to help manage costs (the VM will automatically shutdown as 18:30 each day)
* Installs the Microsoft Anti-Malware software

## Pre-Requisites General

Access to an Azure subscription.

To check if you have an Azure subscription visit the [Azure Portal](https://portal.azure.com/).

Note - if you have just joined [https://my.visualstudio.com](https://my.visualstudio.com/), you will need to visit this site to activate your subscription.

### Pre-Requisites: On Windows

Install **PowerShell Core**

- You can do this by downloading and running the [MSI installer for PowerShell Core from GitHub](https://github.com/PowerShell/PowerShell/releases/download/v7.1.3/PowerShell-7.1.3-win-x64.msi).

- Use all of the default settings when the installer runs.

Install **Chocolatey**

- Chocolatey is a tool for installing software onto Windows.  It takes care of a lot of the pain in installing software.

-  To install, follow the instructions at [Installing Chocolatey ](https://chocolatey.org/install).

Use Chocolatey to install **Git** and **Bicep**:

    `choco install -y git visualstudiocode azure-cli`

### Pre-Requisites: On MacOS

Install **Brew**

- Brew is a tool for installing software onto Macs.  It takes care of a lot of the pain in installing software.

-  To install, follow the instructions at [Brew](https://brew.sh).

Use Brew to install **PowerShell Core**:

    `brew install --cask powershell`

Use Brew to install **Git**:

    `brew install git`

Use Brew to install **Bicep**:

    `brew tap azure/bicep`

    `brew install bicep`

### Pre-requisites: Set Up PowerShell (Windows and Mac)

Launch a PowerShell core session:

    `pwsh`

Install the [PowerShell Az](https://www.powershellgallery.com/packages/Az/5.9.0) package which is required to connect to Azure:

    `Install-Module -Name Az -RequiredVersion 5.9.0 -Scope CurrentUser -AllowClobber`

Establish a connection to Azure using your credentials:

    `Connect-AzAccount`

Point PowerShell at the Azure subscription where you want to create the resources

    `Set-AzContext -SubscriptionId <mpn-subscription-id>`

For example:

    `Set-AzContext -SubscriptionId "Visual Studio Enterprise Subscription – MPN"`

Note - throughout this process, environment variables (like PATH) will change. So you will need to close / reopen your shell to get access to new tools that are installed such as Chocolately.

## Usage

If you have not already done so, clone this repository locally so that you can run the script:

    `git clone https://github.com/endjin/endjin-workstation-setup.git`

Change directory to the repo above:

    `cd endjin-workstation-setup`

Run the `deploy.ps1` script, which take the following parameters:

* BaseName - a naming prefix that will be used when creating the various Azure resources
* AdminPassword - the password used to login the VM

For example:
```
./deploy.ps1 -BaseName "<your-initials>-wrkstn"
```

You will then be prompted to enter a password which will be masked as you type - ensure you keep a note of this in a password manager.

Next you will be asked to confirm that the displayed Azure subscription details are correct (i.e. you are connected to the correct subscription) and then the automation will run through.

Once this has finished, connect to the [Azure Portal](https://portal.azure.com) and you should be able to find a new resource group in your subscription with the name: `rg-<basename>-workstation`.
