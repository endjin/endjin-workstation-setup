# Install BoxStarter & Chocolatey
function _log([string] $msg) { "### $(Get-Date) $msg" >> c:/WindowsAzure/vm-bootstrap.log }

_log "################################"
_log "################################"

_log "### Setting ExecutionPolicy..."
Set-ExecutionPolicy RemoteSigned -Force

_log "Bootstrapping BoxStarter..."
. { Invoke-WebRequest -UseBasicParsing https://boxstarter.org/bootstrapper.ps1 } | Invoke-Expression; Get-Boxstarter -Force
_log "BoxStarter bootstrap complete"

_log "Running bootstrap script..."
# Workaround issue with TEMP path getting polluted due to Boxstarter issue: https://github.com/chocolatey/boxstarter/issues/241
$cachePath = (Resolve-Path ([IO.Path]::Combine($env:USERPROFILE, 'AppData', 'Local', 'Temp', 'chocolatey'))).Path

# This script is run in the system context (rather than as a logged-in user), so we only install the minimum pre-requisites
choco install --nocolor --cacheLocation=$cachePath -y git 2>&1 >>  c:/WindowsAzure/vm-bootstrap.log     # install git
_log "Bootstrap script complete"

_log "Apply Windows Updates..."
Install-WindowsUpdate -Criteria "IsInstalled=0 and Type='Software'" -AcceptEula -SuppressReboot
_log "Windows Updates complete"

_log "Rebooting..."
shutdown /r /t 0
