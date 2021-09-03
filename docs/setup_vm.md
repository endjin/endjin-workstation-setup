# Using an Azure Virtual Machine

To support this scenario, the repo contains a set of [Bicep](https://github.com/Azure/bicep/blob/main/README.md) templates that do the following:

* Create a Windows 10 virtual machine with the Office 365 apps installed
* Enables RDP access for the public IP of the user running the script
* Enables an auto-shutdown policy to help manage costs (the VM will automatically shutdown at 18:30 each day)
* Installs the Microsoft Anti-Malware software
* Installs the software pre-requisites needed to work with this repository


## Pre-Requisites: General
In order to run the automation scripts that will provision your Azure virtual machine, you will require access to an Azure subscription.

To check if you have an Azure subscription visit the [Azure Portal](https://portal.azure.com/).

>Note: If you have just joined, you will need to visit this [site](https://my.visualstudio.com/) to activate your subscription.

## Pre-Requisites: On Windows

Install **PowerShell Core**

* Downloaded location: https://github.com/PowerShell/PowerShell/releases/download/v7.1.4/PowerShell-7.1.4-win-x64.msi
* Use all of the default settings when the installer runs

Install **Chocolatey**

- Chocolatey is a tool for installing software onto Windows.  It takes care of a lot of the pain in installing software.

-  To install, follow the instructions at [Installing Chocolatey ](https://chocolatey.org/install).

Use Chocolatey to install **Git** and **Bicep**:

    `choco install -y git visualstudiocode azure-cli`

## Pre-Requisites: On MacOS

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

## Pre-requisites: Set Up PowerShell (Windows and Mac)

Launch a PowerShell core session:

    `pwsh`

Install the [PowerShell Az](https://www.powershellgallery.com/packages/Az/5.9.0) package which is required to connect to Azure:

    * `Install-Module -Name Az -RequiredVersion 5.9.0 -Scope CurrentUser -AllowClobber`

Establish a connection to Azure using your credentials:

    `Connect-AzAccount`

Point PowerShell at the Azure subscription where you want to create the resources

    `Set-AzContext -SubscriptionId <mpn-subscription-id>`

For example:

    `Set-AzContext -SubscriptionId "Visual Studio Enterprise Subscription – MPN"`

Note - throughout this process, environment variables (like PATH) will change. So you will need to close / reopen your shell to get access to new tools that are installed such as Chocolately.

## Creating the Virtual Virtual

If you have not already done so, clone this repository locally so that you can run the script:

    `git clone https://github.com/endjin/endjin-workstation-setup.git`

Change directory to the repo above:

    `cd endjin-workstation-setup`

Run the `deploy.ps1` script, which take the following parameters:

* BaseName - a naming prefix that will be used when creating the various Azure resources

For example:
```
./deploy.ps1 -BaseName "<your-initials>-wrkstn"
```

You will then be prompted to enter a password which will be masked as you type - ensure you keep a note of this in a password manager.

Next you will be asked to confirm that the displayed Azure subscription details are correct (i.e. you are connected to the correct subscription) and then the automation will run through.

Once this has finished, connect to the [Azure Portal](https://portal.azure.com) and you should be able to find a new resource group in your subscription with the name: `rg-<basename>-workstation`.


## Validate Virtual Machine Access

Locate the virtual machine resource in the above resource group and from it's "Overview" pane, click the "Connect" tab to get details for using RDP to access your new virtual machine.

Logon to the virtual machine via Remote Desktop (RDP) and check whether 'git' has been installed by typing the following from a 'Command Prompt':
```
git
```
The above should return a screen full of usage information.

If you get a message saying the command 'git' could not be found, then something went wrong with the bootstrap process, but you should find you do have the following file available:
* `C:\Packages\Plugins\Microsoft.Compute.CustomScriptExtension\1.10.12\Downloads\0\bootstrap.ps1`

If so, then you can re-run the bootstrap process from an elevated 'Command Prompt' as follows:
```
cd C:\Packages\Plugins\Microsoft.Compute.CustomScriptExtension\1.10.12\Downloads\0
powershell -ExecutionPolicy Unrestricted -File bootstrap.ps1
```

This should install the few pre-requisites needed before proceeding to the next section.


## Installing Windows Subsystem for Linux

This component is used as part of setting-up Docker.

Make sure that your VM is sized to support "embedded virtualisation".  For example VM size: "Standard D4ds_V4".

You then need to install WSL2 on the VM.  Follow the steps below - see [here](https://docs.microsoft.com/en-us/windows/wsl/install-win10) for additional background.

**Step 1** - enable the "Windows Subsystem for Linux" optional feature before installing any Linux distributions on Windows.

```PowerShell
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
```

**Step 2** - before installing WSL 2, you must enable the Virtual Machine Platform optional feature.

```PowerShell
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all
```

**Step 3** - you should now be asked to reboot your machine, say "yes" to allow the above changes to take effect.

**Step 4** - log back into your machine and download the latest [package WSL2 Linux kernel update package for x64 machines](https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi).

**Step 5** - install the above by double-clicking on the file (or opening it from your browser 'Downloads' area)

**Step 6** - set WSL 2 as the default version when installing a new Linux distribution:

```PowerShell
wsl --set-default-version 2
```

Notes:
1. Could some of the steps above be executed using Chocolatey?
1. Are some of the steps redundant given Docker may execute them on install?
1. Is the "Standard D4ds_V4" size of VM the most cost effective option that supports "embedded virtualisation"?


You can now return the main [README](/README.md#managing_your_installed_software) to configure the additional software you require on the virtual machine.
