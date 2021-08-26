# Install BoxStarter & Chocolatey
function _log([string] $msg) { "### $(Get-Date) $msg" >> c:/WindowsAzure/vm-bootstrap.log }

_log "################################"
_log "################################"

_log "### Setting ExecutionPolicy..."
Set-ExecutionPolicy RemoteSigned -Force

_log "Bootstrapping BoxStarter..."
. { Invoke-WebRequest -UseBasicParsing https://boxstarter.org/bootstrapper.ps1 } | Invoke-Expression; Get-Boxstarter -Force
_log "BoxStarter bootstrap complete"

$starterPackage = 'https://raw.githubusercontent.com/endjin/endjin-workstation-setup/feature/choco/bootstrap/bootstrap-boxstarter-script.txt'
_log "Running bootstrap script..."
Install-BoxStarterPackage -PackageName $starterPackage -DisableReboots
_log "Bootstrap script complete"

_log "Installing WSL..."
wsl --install >> c:/WindowsAzure/vm-bootstrap.log
_log "WSL install complete"

_log "Rebooting..."
shutdown /r /t 0
