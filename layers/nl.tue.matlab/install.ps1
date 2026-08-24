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

# Copy Tools folder to C:\
Copy-Item -Path .\matlab_resources\Tools -Destination C:\ -recurse

# Start installation of Matlab
Start-Process -FilePath .\matlab_resources\MathWorks\bin\win64\MathWorksProductInstaller.exe -ArgumentList "-inputFile .\matlab_resources\installer_input.txt" -Wait -NoNewWindow
# Wait till installation is ready...

# Block Edge to https://www.mathworks.com/matlabcentral
$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Edge\URLBlocklist"
$Name = "1"
$value = "https://www.mathworks.com/matlabcentral"
New-Item -Path $registryPath -Force | Out-Null
New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType String -Force | Out-Null

# Create scheduled task to warm up Matlab on user login. This reduces the time it takes for the application to start on first use by students.
$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument "C:\Tools\WarmUpMatlab.ps1"
$trigger = New-ScheduledTaskTrigger -AtLogOn
$principal = New-ScheduledTaskPrincipal -GroupId "Users" -RunLevel Limited
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "Warmup ML" -Principal $principal -Description "Warming up Matlab" 
