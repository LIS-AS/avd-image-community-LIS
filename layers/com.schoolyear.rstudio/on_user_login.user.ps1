$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# The main purpose of this script is to set up RStudio in order to use our Session Host Proxy.
# Which in turn is configured to whitelist the hosts specified in our properties.json5 file.
# Configuring RStudio to use a proxy is as simple as setting some env variables that are loaded by RStudio on startup.
# This can be done by creating a `.Renviron` file in the user's `Documents` directory that tells RStudio the ip addr of the proxy to use
# If you do NOT want to allow for the installation of external R packages you can remove this file
# from the final build

# Create the .Renviron file
$documentsFolder = [System.Environment]::GetFolderPath("MyDocuments")
$renvironFilePath = Join-Path -Path $documentsFolder -ChildPath ".Renviron"

# Define the content to write into .Renviron
$renvironFileContent = @"
options(internet.info = 0)
http_proxy=http://proxies.local:8080
https_proxy=http://proxies.local:8080
"@

Write-Host "Writing .Renviron file at: $renvironFilePath"
# Write the file (creates it if it doesn't exist)
Set-Content -Path $renvironFilePath -Value $renvironFileContent
Write-Host "Wrote $renvironFilePath"

# Now our RStudio installation should pick up on our `.Renviron` file and properly use the proxy if it needs to install any extra R packages

# Adding RStudio icon to the taskbar and desktop.
$targetPath = "C:\Program Files\RStudio\rstudio.exe"
$desktopPath = [Environment]::GetFolderPath("Desktop")
$shortcutName = "RStudio.lnk"
$shortcutPath = Join-Path $desktopPath $shortcutName
$startMenuPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\$shortcutName"
$toolsDir = "C:\Tools"
$pttbPath = Join-Path $toolsDir "pttb.exe"
# Create shortcut on Desktop
$WScriptShell = New-Object -ComObject WScript.Shell
$desktopShortcut = $WScriptShell.CreateShortcut($shortcutPath)
$desktopShortcut.TargetPath = $targetPath
$desktopShortcut.WorkingDirectory = Split-Path $targetPath
$desktopShortcut.IconLocation = "$targetPath, 0"
$desktopShortcut.Save()
# Copy shortcut to Start menu
Copy-Item -Path $shortcutPath -Destination $startMenuPath -Force
# Pin icon to taskbar using pttb.exe
Start-Process -FilePath $pttbPath -ArgumentList "`"$targetPath`"" -Wait

# Adding Explorer icon to the taskbar and desktop.
$targetPath = "C:\Windows\explorer.exe"
$desktopPath = [Environment]::GetFolderPath("Desktop")
$shortcutName = "File Explorer.lnk"
$shortcutPath = Join-Path $desktopPath $shortcutName
$startMenuPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\$shortcutName"
$toolsDir = "C:\Tools"
$pttbPath = Join-Path $toolsDir "pttb.exe"
# Create File Explorer shortcut on Desktop
$WScriptShell = New-Object -ComObject WScript.Shell
$desktopShortcut = $WScriptShell.CreateShortcut($shortcutPath)
$desktopShortcut.TargetPath = $targetPath
$desktopShortcut.WorkingDirectory = Split-Path $targetPath
$desktopShortcut.IconLocation = "$targetPath, 0"
$desktopShortcut.Save()
# Adds shortcut to Start menu
Copy-Item -Path $shortcutPath -Destination $startMenuPath -Force
# Pin to taskbar using pttb.exe
Start-Process -FilePath $pttbPath -ArgumentList "`"$targetPath`"" -Wait