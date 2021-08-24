$here = Split-Path -Parent $PSCommandPath

Install-BoxStarterPackage -PackageName "$here/setup-boxstarter-script.txt" -DisableReboots
