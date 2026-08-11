# <CAN BE REMOVED>
# This script is executed during the preparation of the exam image
# This script is executed before the sysprep step
#
# This script is executed in its own layer folder
# So, any file in this image layer, is available in the current working directory
#
# Once all installation scripts are executed, all image layer files are deleted
# If you want to persist a file in the image, you must copy it to another folder
# </CAN BE REMOVED>


# Recommended snippet to make sure PowerShell stops execution on failure
# https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_preference_variables?view=powershell-7.5#erroractionpreference
# https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/set-strictmode?view=powershell-7.4
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# Recommended snippet to make sure PowerShell doesn't show a progress bar when downloading files
# This makes the downloads considerably faster
$ProgressPreference = 'SilentlyContinue'

## EXAMPLE: WHITELIST IP
## NOTE: Due to limitations in Azure, only TCP and UDP are supported
## NOTE: It is recommended to configure any IP address or port as a build parameter. These things tend to change **and** allows you to share your layers with others
#
# New-NetFirewallRule -DisplayName 'allow-ip' -Direction Outbound -Action Allow -RemoteAddress '1.2.3.4' -Protocol TCP -RemotePort 8080 -Profile Any -ErrorAction Stop

## EXAMPLE: WHITELIST HOSTNAME
## NOTE: Due to limitations in Azure, only TCP and UDP are supported
## NOTE: It is recommended to configure any IP address or port as a build parameter. These things tend to change **and** allows you to share your layers with others
## NOTE: Only use hostname whitelisting when you are sure no other resources are hosted on IP(s) to which this hostname resolves.
##       The actual IP addresses of this hostname will be whitelisted. Any resource hosted on these servers will be accessible to students. Not only the hostname you configure here
#
# New-NetFirewallDynamicKeywordAddress -Id "{any-unique-guid}" -Keyword "example.com" -AutoResolve $true
# New-NetFirewallRule -DisplayName "Allow All Outbound to example.com" -Direction Outbound -Action Allow -RemoteDynamicKeywordAddresses (Get-NetFirewallDynamicKeywordAddress -Keyword "example.com").ID

# Run the installer silently with logging
Start-Process -FilePath ".\mathematica_resources\setup.exe" -ArgumentList '/NORESTART','/SILENT','/SUPPRESSMSGBOXES','/LOG="C:\Windows\Temp\install.log"' -Wait

# Create the licensing directory (creates parent folders if needed)
New-Item -ItemType Directory -Path "C:\ProgramData\Wolfram\Licensing" -Force

# Copy the mathpass file
Copy-Item -Path ".\mathematica_resources\mathpass" -Destination "C:\ProgramData\Wolfram\Licensing\mathpass" -Force

# Copy init.m to a location where it can be picked-up by the user script.
New-Item -ItemType Directory -Path "C:\temp" -Force
Copy-Item -Path ".\mathematica_resources\init.m" -Destination "C:\temp\init.m" -Force

# Install helpfiles (11Gb diskspace is needed for this)
# Start-Process -FilePath ".\mathematica_resources\Wolfram_App_14.3_and_English_Documentation\M-WIN-Documentation.en-us-14.3.0-11908168.msi" -ArgumentList '/quiet' -Wait

# remove install files to save diskspace
Remove-Item ".\mathematica_resources" -Force -Recurse

