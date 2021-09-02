$here = Split-Path -Parent $PSCommandPath

Install-BoxStarterPackage -PackageName "$here/setup-boxstarter-script.txt" -DisableReboots

Write-Host "`n*******************************************************************"
Write-Host "*** If this is the first time you have run this script, you will"
Write-Host "*** need to reboot your machine to complete the WSL installation"
Write-Host "*** before Docker Desktop will work properly."
Write-Host "*******************************************************************`n"
