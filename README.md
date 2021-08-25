# endjin-workstation-setup

This repository helps you setup your development workstation and provides an ongoing mechanism for managing the software you need.

It targets two core scenarios:

1. Using an Azure virtual machine - go [here](#using-an-azure-virtual-machine) to get started
1. Using an existing Windows system you already have access to (e.g. a new laptop) - go [here](#using-an-existing-windows-machine) to get started

The intention is that you fork this repo into your own GitHub account and customise the configuration as required - this repo will then provide you with a mechanism to rapidly get yourself up-and-running in the event of using a new machine or after fresh install of Windows on your existing machine.


## Using an Azure Virtual Machine
To support this scenario, the repo contains a set of [Bicep](https://github.com/Azure/bicep/blob/main/README.md) templates that do the following:

* Create a Windows 10 virtual machine with the Office 365 apps installed
* Enables RDP access for the public IP of the user running the script
* Enables an auto-shutdown policy to help manage costs (the VM will automatically shutdown at 18:30 each day)
* Installs the Microsoft Anti-Malware software
* Installs the software pre-requisites needed to work with this repository

The simplest way to provision this virtual machine is to use the button below:
[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fendjin%2Fendjin-workstation-setup%2Ffeature%2Fchoco%2Fazuredeploy.json)

Alternatively, you can setup and run the automation included in this repository.

### Pre-Requisites: General
In order to run the automation scripts that will provision your Azure virtual machine, you will require access to an Azure subscription.

To check if you have an Azure subscription visit the [Azure Portal](https://portal.azure.com/).

>Note: If you have just joined, you will need to visit this [site](https://my.visualstudio.com/) to activate your subscription.

### Pre-Requisites: On Windows

Install **PowerShell Core**

* Downloaded location: https://github.com/PowerShell/PowerShell/releases/download/v7.1.4/PowerShell-7.1.4-win-x64.msi
* Use all of the default settings when the installer runs

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

    * `Install-Module -Name Az -RequiredVersion 5.9.0 -Scope CurrentUser -AllowClobber`

Establish a connection to Azure using your credentials:

    `Connect-AzAccount`

Point PowerShell at the Azure subscription where you want to create the resources

    `Set-AzContext -SubscriptionId <mpn-subscription-id>`

For example:

    `Set-AzContext -SubscriptionId "Visual Studio Enterprise Subscription – MPN"`

Note - throughout this process, environment variables (like PATH) will change. So you will need to close / reopen your shell to get access to new tools that are installed such as Chocolately.

### Creating the Virtual Virtual

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

## Steps to follow after VM has been created...

Make sure that your VM is sized to support "embedded virtualisation".  For example VM size: "Standard D4ds_V4".

You then need to install WSL2 on the VM.  Follow the steps below - see [here](https://docs.microsoft.com/en-us/windows/wsl/install-win10) for additional background.

**Step 1** - enable the "Windows Subsystem for Linux" optional feature before installing any Linux distributions on Windows.

```PowerShell
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
```

**Step 2** - before installing WSL 2, you must enable the Virtual Machine Platform optional feature.

```PowerShell
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
```

**Step 3** - download the latest [package WSL2 Linux kernel update package for x64 machines](https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi).

**Step 4** - set WSL 2 as the default version when installing a new Linux distribution:

```PowerShell
wsl --set-default-version 2
```

Notes:

1. Could some of the steps above be executed using Chocolatey?
1. Are some of the steps redundant given Docker may execute them on install?
1. Is the "Standard D4ds_V4" size of VM the most cost effective option that supports "embedded virtualisation"?


### Validate Virtual Machine Access

Locate the virtual machine resource in the above resource group and from it's "Overview" pane, click the "Connect" tab to get details for using RDP to access your new virtual machine.

Logon to the virtual machine via Remote Desktop (RDP) and check whether you have 'PowerShell 7 (x64)' available in the Start Menu.

If you don't then something went wrong with the bootstrap process, but you should find you do have the following file available:
* `C:\Packages\Plugins\Microsoft.Compute.CustomScriptExtension\1.10.12\Downloads\0\bootstrap.ps1`

If so, then you can re-run the bootstrap process from an elevated 'Command Prompt' as follows:
```
cd C:\Packages\Plugins\Microsoft.Compute.CustomScriptExtension\1.10.12\Downloads\0
powershell -ExecutionPolicy Unrestricted -File bootstrap.ps1
```

This should install the few pre-requisites needed before proceeding to the next section below [Using an Existing Windows Machine](#using-an-existing-windows-machine).


## Using an Existing Windows Machine

If you already have a suitable Windows machine, then check whether you have the following pre-requisites already available:

* PowerShell Core
* Git
* Your preferred editor/IDE (e.g. Visual Studio Code)

If you do not have those available, then you can run the following from an elevated Windows PowerShell terminal to install them before proceeding to the next section:

```
. { iwr -useb https://raw.githubusercontent.com/endjin/endjin-workstation-setup/main/bootstrap/bootstrap.ps1 -Headers @{"Cache-Control"="no-cache"} } | iex;
```

>NOTE: Windows PowerShell is the older, non-cross platform version of PowerShell which comes pre-installed with Windows.  Given that this flavour of PowerShell is no longer being updated (it is locked at v5.1), we have adopted PowerShell Core as our standard which is currently at v7.x.


## Managing your installed software

1. If you haven't already done so, fork this repository into your own GitHub account
1. Create a directory where you will store all the git repositories you work with (e.g. `C:\git`)
1. Open a new elevated 'Windows PowerShell' terminal from the Start Menu
1. `cd` into the folder you created above
1. Clone this repository to your machine: `git clone https://github.com/<your-github-username>/endjin-workstation-setup.git`
1. `cd` into `endjin-workstation-setup` directory created by the above command
1. Review the `setup-boxstarter-script.txt` file, removing/commenting-out any lines as desired - this file contains comments to describe what each line does
1. Review the `setup-chocolatey-packages.config` file, adding any further packages you require - they can be found by searching [here](https://community.chocolatey.org/packages)
1. Run `./setup.ps1` to begin the software install process
1. Commit any changes you made to the above files and push them up to GitHub so they are safely stored
