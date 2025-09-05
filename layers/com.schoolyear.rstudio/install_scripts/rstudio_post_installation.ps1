Param (
  [Parameter(Mandatory = $true)]
  [string]$rVersion
)

$ProgressPreference = 'SilentlyContinue'

# After we've successfully installed R & RStudio we need to configure RStudio to find the necessary R version.
# In order to do so we need to copy over some RStudio specific AppData files.

# Whenever we want to write some files to the sessionhost user we can put them into `C:\Users\Default`
# On Windows, the `Default` user is used by the system to prepare the `Home` directory of newly created users.
# Since our `SessionHost` users are not created yet, we can place files inside `C:\Users\Default`

Write-Host "Entering rstudio post-installation..."

# We start by checking if `C:\Users\Default\AppData\Roaming\RStudio` exists and if it does we delete it
$defaultUser = "C:\Users\Default"
$rStudioDataPath = "$defaultUser\AppData\Roaming\RStudio"
if (Test-Path $rStudioDataPath) {
  Write-Host "Removing $rStudioDataPath..."
  Remove-Item -Path $rstudioDataPath -Recurse | Out-Null
}

$rstudioResourcesPath = ".\rstudio_resources"

Write-Host "Creating $rStudioDataPath..."
New-Item -Path $rstudioDataPath -ItemType Directory | Out-Null

# We copy over:

# A `config.json` file containing some pre-existing configuration from an already tested R & RStudio installation.
# The most important part of this file is the configuration of the `rExecutablePath=...` which tells RStudio
# the first time it starts up the path of the installed R Version we want to use.
Write-Host "Copying over config.json with search-replace version..."
(Get-Content -Path "$rstudioResourcesPath\RStudio_config\config.json" -Raw) -replace "R-0.0.0", "R-$rVersion" | Set-Content -Path "$rStudioDataPath\config.json"

# A `rstudio-prefs.json` file which contains the `Cran mirror` we want RStudio to use when downloading packages.
Write-Host "Copying over rstudio-prefs.json"
Copy-Item "$rstudioResourcesPath\RStudio_config\rstudio-prefs.json" "$rStudioDataPath\rstudio-prefs.json"

#A `.Rprofile` file containing a command to add the `Tinytex` path to the environment variables. `Tinytex` is needed for PDF generation.
Write-Host "Copying over .Rprofile"
Copy-Item "$rstudioResourcesPath\RStudio_config\.Rprofile" "$defaultUser\Documents\.Rprofile"

# By creating an empty file named `crash-handler-permission` in AppData 
# we inform RStudio that we do not want it to send data back to cran containing possible crashes.
# This also disables an annoying pop-up during exams which can be disruptive to the user's experience.
$rStudioLocalPath = "$defaultUser\AppData\Local\RStudio"
if (Test-Path $rStudioLocalPath) {
  Write-Host "Removing $rStudioLocalPath..."
  Remove-Item -Path $rStudioLocalPath -Recurse | Out-Null
}
$crashHandlerPermission = "$rStudioLocalPath\crash-handler-permission"
Write-Host "Creating $crashHandlerPermission..."
New-Item $crashHandlerPermission -Force | Out-Null
Write-Host "Created $crashHandlerPermission"

# We want RStudio to have some packages pre-installed, we put those packages
# in `install_packages.r` and execute it. These packagess are necessary for
# PDF and R Markdown file generation.
$rInstallFolder = "C:\Program Files\R\R-$rVersion"
$rScriptPath = "$rInstallFolder\bin\Rscript.exe"
$rInstallScriptPath = "$rstudioResourcesPath\install_packages.r"
try {
  Write-Host "Pre-installing default packages"
  Start-Process -FilePath $rScriptPath -ArgumentList $rInstallScriptPath -Wait -NoNewWindow -RedirectStandardOutput stdout -RedirectStandardError stderr
  Write-Host "[DONE]"
} catch {
  Write-Error "Failed to run install_packages.r"
}