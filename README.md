# endjin-workstation-setup

This repository helps you setup your development workstation and provides an ongoing mechanism for managing the software you need.

It targets two core scenarios:

1. Using an Azure virtual machine - go [here](docs/setup_vm.md) to get started
1. Using an existing Windows system you already have access to (e.g. a new laptop) - go [here](#using-an-existing-windows-machine) to get started

The intention is that you fork this repo into your own GitHub account and customise the configuration as required - this repo will then provide you with a mechanism to rapidly get yourself up-and-running in the event of using a new machine or after fresh install of Windows on your existing machine.


## Using an Existing Windows Machine

If you already have a suitable Windows machine, then check whether you have the following pre-requisites already available:


**PowerShell Core**

- You can do this by downloading and running the [MSI installer for PowerShell Core from GitHub](https://github.com/PowerShell/PowerShell/releases/download/v7.1.3/PowerShell-7.1.3-win-x64.msi).

- Use all of the default settings when the installer runs.

**Chocolatey**

- Chocolatey is a tool for installing software onto Windows.  It takes care of a lot of the pain in installing software.

-  To install, follow the instructions at [Installing Chocolatey ](https://chocolatey.org/install).


Use Chocolatey to install **Git**:

    `choco install -y git`

### Installing Windows Subsystem for Linux (aka WSL)

For the moment the most reliable way to install Windows Subsystem for Linux is to follow the manual process documented [here](docs/setup_vm.md#installing-windows-subsystem-for-linux)

## Managing your installed software

1. If you haven't already done so, fork this repository into your own GitHub account via the 'Fork' option in the top right of this page you are reading
1. Create a directory where you will store all the git repositories you work with (e.g. `C:\code`)
1. Open a new elevated 'Windows PowerShell' terminal from the Start Menu (Run as Administrator)
1. `cd` into the folder you created above
1. Clone this repository to your machine: `git clone https://github.com/<your-github-username>/endjin-workstation-setup.git`
1. `cd` into `endjin-workstation-setup` directory created by the above command
1. Review the `setup-chocolatey-packages.config` file, adding any further packages you require - they can be found by searching [here](https://community.chocolatey.org/packages)
1. Allow local powershell scripts to executed by running `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force`
1. Run `./setup.ps1` to begin the software install process
1. Commit any changes you made to the above files and push them up to GitHub so they are safely stored
