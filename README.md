# endjin-workstation-setup

This repository helps you setup a Azure virtual machine that you can use a workstation. It also serves as an introduction to working with infrastructure in the Azure cloud.

The intention is that you fork this repo into your own GitHub account and customise the virtual machine as required.

## Overview
The repo targets two scenarios to help streamline setting-up a new development workstation:

1. Using an Azure virtual machine - go [here](#using-an-azure-virtual-machine) to get started
1. Using an existing Windows system you already have access to (e.g. a new laptop) - go [here](#using-an-existing-windows-machine) to get started


## Using an Azure Virtual Machine
To support this scenario, the repo contains a set of [Bicep](https://github.com/Azure/bicep/blob/main/README.md) templates that do the following:

* Create a Windows 10 virtual machine with the Office 365 apps installed
* Enables RDP access for the public IP of the user running this scripts
* Enables an auto-shutdown policy to help manage costs (the VM will automatically shutdown as 18:30 each day)
* Installs the Microsoft Anti-Malware software

### Pre-Requisites
In order to run the automation scripts that will provision your Azure virtual machine, you will require:

1. Access to an Azure subscription (it is suggested that you use your Visual Studio or 'MPN' subscription for this)
1. PowerShell Core installed:
    * Windows: https://github.com/PowerShell/PowerShell/releases/download/v7.1.4/PowerShell-7.1.4-win-x64.msi
    * Mac: https://github.com/PowerShell/PowerShell/releases/download/v7.1.4/powershell-7.1.4-osx-x64.pkg
1. [PowerShell Az](https://www.powershellgallery.com/packages/Az/5.9.0) module installed:
    * From within an PowerShell Core terminal, run `Install-Module -Name Az -RequiredVersion 5.9.0 -Scope CurrentUser -AllowClobber`
1. Logged-in to the above module:
    * `Connect-AzAccount`
1. Connected to the correct subscription:
    * `Set-AzContext -SubscriptionId <mpn-subscription-id>`

### Creating the Virtual Virtual

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

Locate the virtual machine resource and from it's "Overview" pane, click the "Connect" tab to get details for how to connect to your new virtual machine.


## Using an Existing Windows Machine

If you already have a suitable Windows machine, then check whether you have the following pre-requisites already available:

* PowerShell Core
* Git
* Your preferred editor/IDE (e.g. Visual Studio Code)

If you do not have those available, then you can run the following from an elevated Windows PowerShell terminal to install them before proceeding to the next section:

```
. { iwr -useb https://raw.githubusercontent.com/endjin/dev-workstation-choco-demo/master/bootstrap.ps1 -Headers @{"Cache-Control"="no-cache"} } | iex;
```

>NOTE: Windows PowerShell is the older, non-cross platform version of PowerShell which comes pre-installed with Windows.  Given that this flavour of PowerShell is no longer being updated (it is locked at v5.1), we have adopted PowerShell Core as our standard which is currently at v7.x.


## Managing your installed software

1. If you haven't already done so, fork this repository into your own GitHub account
1. Open a new PowerShell Core terminal
1. Clone this repository to your machine: `git clone https://github.com/<your-github-username>/endjin-workstation-setup.git`
1. Review the `setup-boxstarter-script.txt` file, removing/commenting-out any lines as desired - this file contains comments to describe what each line does
1. Review the `setup-chocolatey-packages.config` file, adding any further packages you require - they can be found by searching [here](https://community.chocolatey.org/packages)
1. `cd` into `endjin-workstation-setup` directory created by the above command
1. Run `./setup.ps1` to begin the software install process
