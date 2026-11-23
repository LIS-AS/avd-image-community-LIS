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

#Param (
#    [Parameter(Mandatory = $true)]
#    [string]$exampleParameter,                  # You can configure your own paramter in the properties.json5 file
#
#    [Parameter(ValueFromRemainingArguments)]
#    [string[]]$RemainingArgs                    # To make sure this script doesn't break when new parameters are added
#)

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
New-NetFirewallRule -DisplayName 'NetBeans Repository' -Direction Outbound -Action Allow -RemoteAddress '104.18.19.12','104.18.18.12' -Protocol TCP -RemotePort Any -Profile Any -ErrorAction Stop

# Installing software in this layer
$scriptLogPrefix = "NetBeans"

Write-Host "${scriptLogPrefix}: Installing JDK"
& .\Install_Scripts\Install_JDK.ps1
Write-Host "${scriptLogPrefix}: Done installing JDK"

Write-Host "${scriptLogPrefix}: Installing NetBeans"
& .\Install_Scripts\Install_NetBeans.ps1
Write-Host "${scriptLogPrefix}: Done installing NetBeans"

Write-Host "${scriptLogPrefix}: Setting up shortcuts"
& .\Install_Scripts\Shortcuts.ps1
Write-Host "${scriptLogPrefix}: Done setting up shortcuts" 
