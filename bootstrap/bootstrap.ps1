# Install BoxStarter & Chocolatey
function _log([string] $msg) { "### $(Get-Date) $msg" >> c:/WindowsAzure/vm-bootstrap.log }

_log "################################"
_log "################################"

_log "### Setting ExecutionPolicy..."
Set-ExecutionPolicy RemoteSigned -Force

_log "Bootstrapping BoxStarter..."
. { Invoke-WebRequest -UseBasicParsing https://boxstarter.org/bootstrapper.ps1 } | Invoke-Expression; Get-Boxstarter -Force
_log "BoxStarter bootstrap complete"

#$starterPackage = 'https://raw.githubusercontent.com/endjin/endjin-workstation-setup/feature/choco/bootstrap/bootstrap-boxstarter-script.txt'
_log "Running bootstrap script..."
#Install-BoxStarterPackage -PackageName $starterPackage -DisableReboots
# Workaround issue with TEMP path getting polluted due to Boxstarter issue: https://github.com/chocolatey/boxstarter/issues/241
$cachePath = (Resolve-Path ([IO.Path]::Combine($env:USERPROFILE, 'AppData', 'Local', 'Temp', 'chocolatey'))).Path
# choco install --nocolor --cacheLocation=$cachePath -y powershell-core 2>&1 >>  c:/WindowsAzure/vm-bootstrap.log
choco install --nocolor --cacheLocation=$cachePath -y git 2>&1 >>  c:/WindowsAzure/vm-bootstrap.log
# choco install --nocolor --cacheLocation=$cachePath -y vscode 2>&1 >>  c:/WindowsAzure/vm-bootstrap.log
_log "Bootstrap script complete"

# _log "Apply Windows Updates..."
# Install-WindowsUpdate -Criteria "IsInstalled=0 and Type='Software'" -AcceptEula -SuppressReboot
# _log "Windows Updates complete"

_log "Installing WSL..."
#wsl --install >> c:/WindowsAzure/vm-bootstrap.log
# dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart >> c:/WindowsAzure/vm-bootstrap.log
# dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart >> c:/WindowsAzure/vm-bootstrap.log
# Invoke-WebRequest -Uri "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi" -OutFile ./wsl_update_x64.msi
# & msiexec.exe /i $((Resolve-Path ./wsl_update_x64.msi).Path) /passive /l*v c:/WindowsAzure/wsl2-install.log | Out-Null
# "MSIExec code: $LASTEXITCODE" >> c:/WindowsAzure/vm-bootstrap.log
#wsl --set-default-version 2 >> c:/WindowsAzure/vm-bootstrap.log
# _log "WSL install complete"

#_log "Rebooting..."
# shutdown /r /t 0
