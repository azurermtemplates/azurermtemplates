[CmdletBinding()]
Param([Parameter(Mandatory=$True,Position=1)][string]$Application)


# Install Cholcolatey
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install Appliction
#choco install notepadplusplus.install
choco install $Application
