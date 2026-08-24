# This script is executed every time a user logs into the VM which may be more than once
# Keep in mind that the student is waiting in the exam session for this script to finish
# You should not do any long running actions
#
# This script is executed as the user logging in, typically without admin rights

Param (
    [Parameter(Mandatory = $true)]
    [string]$uid,          # SID of the Windows user logging in

    [Parameter(Mandatory = $true)]
    [string]$gid,          # SID of the Windows user logging in

    [Parameter(Mandatory = $true)]
    [string]$username,     # Username of the Windows user logging in

    [Parameter(Mandatory = $true)]
    [string]$homedir,      # Absolute path to the user's home directory

    # To make sure this script doesn't break when new parameters are added
    [Parameter(ValueFromRemainingArguments)]
    [string[]]$RemainingArgs
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# copy settings file to disable Copilot in the interface.
New-Item -Path "$env:APPDATA\MathWorks\MATLAB\R2026a" -ItemType Directory -Force 
Copy-Item -Path C:\tools\matlab.mlsettings -Destination "$env:APPDATA\MathWorks\MATLAB\R2026a"

# set cookies in Edge to force language/location of Matlab help page to US. other languages direct to a webpage that is not whitelisted.
Start-Process -Wait -FilePath "C:\tools\pw\node.exe" -ArgumentList "C:\tools\set-cookies.js"
Copy-Item -Path "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Temp\*" -Destination "$env:LOCALAPPDATA\Microsoft\Edge\User Data\" -recurse -Force

# # matlab warmup, no logon is asked during first start of Matlab
# $scriptLogPrefix = "Matlab warm-up"
# $applicationPath = "C:\Program Files\MATLAB\R2026a\bin\matlab.exe"
# $warmupSeconds = 90
# $processName = "matlab"
# $processDetectionSeconds = 0
# 
# # Start application, then stop it after a delay. This reduces the time it takes for the application to start on first use by students.
# if (!(Test-Path -LiteralPath $applicationPath)) {
#   Write-Warning "${scriptLogPrefix}: Skipping warm-up because $applicationPath was not found."
#   return
# }
# 
# $existingAppProcessIds = @(
#   Get-Process -Name $processName -ErrorAction SilentlyContinue |
#   Select-Object -ExpandProperty Id
# )
# 
# $newApplicationProcesses = @()
# 
# try {
#   Write-Host "${scriptLogPrefix}: Starting application to pre-initialize user data."
#   Start-Process -FilePath $applicationPath | Out-Null
# 
#   $applicationStarted = $false
#   for ($i = 0; $i -lt 120; $i++) {
#     Start-Sleep -Seconds 1
#     $processDetectionSeconds++
#     $newApplicationProcesses = @(
#       Get-Process -Name $processName -ErrorAction SilentlyContinue |
#       Where-Object { $_.Id -notin $existingAppProcessIds }
#     )
# 
#     if ($newApplicationProcesses.Count -gt 0) {
#       $applicationStarted = $true
#       break
#     }
#   }
# 
#   if (-not $applicationStarted) {
#     Write-Warning "${scriptLogPrefix}: Skipping warm-up because no new application process was detected after $processDetectionSeconds seconds."
#     return
#   }
# 
#   Write-Host "${scriptLogPrefix}: Letting application run for $warmupSeconds seconds after startup was detected in $processDetectionSeconds seconds."
#   Start-Sleep -Seconds $warmupSeconds
# } catch {
#   Write-Warning "${scriptLogPrefix}: Warm-up failed: $($_.Exception.Message)"
# } finally {
#   $newApplicationProcesses = @(
#     Get-Process -Name $processName -ErrorAction SilentlyContinue |
#     Where-Object { $_.Id -notin $existingAppProcessIds }
#   )
# 
#   if ($newApplicationProcesses.Count -gt 0) {
#     $newApplicationProcesses | Stop-Process -Force -ErrorAction SilentlyContinue
#     Write-Host "${scriptLogPrefix}: Stopped warm-up application processes after $warmupSeconds seconds of warm-up."
#   }
# }
