$here = Split-Path -Parent $PSCommandPath

Write-Host "`n*******************************************************************"
Write-Host "*** Have you followed the steps for installing the"
Write-Host "*** Windows Subsystem for Linux (aka WSL)?"
Write-Host "*** Link: https://github.com/endjin/endjin-workstation-setup/blob/feature/choco/docs/setup_vm.md#installing-windows-subsystem-for-linux"

# Workaround issue with TEMP path getting polluted due to Boxstarter issue: https://github.com/chocolatey/boxstarter/issues/241
$cachePath = (Resolve-Path ([IO.Path]::Combine($env:USERPROFILE, 'AppData', 'Local', 'Temp', 'chocolatey'))).Path

# Install/upgrade packages using the configuration file
choco install --cacheLocation=$cachePath -y ./setup-chocolatey-packages.config

Write-Host "`n*******************************************************************"
Write-Host "*** If this is the first time you have run this script, you will"
Write-Host "*** need to log out and log back in to your machine before"
Write-Host "*** Docker Desktop will work properly."
Write-Host "*******************************************************************`n"
