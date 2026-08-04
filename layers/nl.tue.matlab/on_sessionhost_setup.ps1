# This script is executed on each sessionhost during deployment
# Note that any time spent in this script adds to the deployment time of each VM (and thus the deployment time of exams)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$scriptLogPrefix = "Matlab warm-up"
$applicationPath = "C:\Program Files\MATLAB\R2026a\bin\matlab.exe"
$warmupSeconds = 180
$processName = "matlab"
$processDetectionSeconds = 0

# Start application, then stop it after a delay. This reduces the time it takes for the application to start on first use by students.
if (!(Test-Path -LiteralPath $applicationPath)) {
  Write-Warning "${scriptLogPrefix}: Skipping warm-up because $applicationPath was not found."
  return
}

$existingAppProcessIds = @(
  Get-Process -Name $processName -ErrorAction SilentlyContinue |
  Select-Object -ExpandProperty Id
)

$newApplicationProcesses = @()

try {
  Write-Host "${scriptLogPrefix}: Starting application to pre-initialize user data."
  Start-Process -FilePath $applicationPath | Out-Null

  $applicationStarted = $false
  for ($i = 0; $i -lt 120; $i++) {
    Start-Sleep -Seconds 1
    $processDetectionSeconds++
    $newApplicationProcesses = @(
      Get-Process -Name $processName -ErrorAction SilentlyContinue |
      Where-Object { $_.Id -notin $existingAppProcessIds }
    )

    if ($newApplicationProcesses.Count -gt 0) {
      $applicationStarted = $true
      break
    }
  }

  if (-not $applicationStarted) {
    Write-Warning "${scriptLogPrefix}: Skipping warm-up because no new application process was detected after $processDetectionSeconds seconds."
    return
  }

  Write-Host "${scriptLogPrefix}: Letting application run for $warmupSeconds seconds after startup was detected in $processDetectionSeconds seconds."
  Start-Sleep -Seconds $warmupSeconds
} catch {
  Write-Warning "${scriptLogPrefix}: Warm-up failed: $($_.Exception.Message)"
} finally {
  $newApplicationProcesses = @(
    Get-Process -Name $processName -ErrorAction SilentlyContinue |
    Where-Object { $_.Id -notin $existingAppProcessIds }
  )

  if ($newApplicationProcesses.Count -gt 0) {
    $newApplicationProcesses | Stop-Process -Force -ErrorAction SilentlyContinue
    Write-Host "${scriptLogPrefix}: Stopped warm-up application processes after $warmupSeconds seconds of warm-up."
  }
}
