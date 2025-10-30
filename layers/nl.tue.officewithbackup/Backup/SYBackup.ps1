## Evert-Jan van de Keuken 
    ## 01-03-2025
    ## info@it-solved.nl
 
    # Set variabeles
    # Change the variabeles $storage_account_azure, $password_azure_share, $user_azure_share, $backup_share_examen_azure
    # You can find this info at the "Connect" button of the fileshare in Azure under "Show script"
    $storage_account_azure = "schoolyearpublic.file.core.windows.net"
    $password_azure_share = "***"
    $user_azure_share = "localhost\schoolyearpublic"
    $backup_share_examen_azure = "\\schoolyearpublic.file.core.windows.net\sybackupfiles" 
    $user = (gci -Path C:\Users | sort -Descending LastWriteTime | select name | select -first 1).Name
    $today = Get-Date -format yyyy_MM_dd
    $exam = $env:computername -split "-" | select -first 1
 
    # Mount the drive
    cmd.exe /C "cmdkey /add:`"$storage_account_azure`" /user:`"$user_azure_share`" /pass:`"$password_azure_share`""
 
    # (optional) Add Firewall rule
    # New-NetFirewallRule -DisplayName "Allow Azure File Share" -Direction Outbound -remoteport 445 -Protocol TCP -Action Allow -remoteaddres "-- adres van het azure storage account --"

    # Loop trough folders

    # Copy the documents an dowload folder, exclude the folders: Folder1, Folder2 and "instructie voor de kandidaat"
    # You can add folder and exclusions here:
    #robocopy `"c:\users\$user\documents`" `"$backup_share_examen_azure\$user\documents`" /E /XO /XD Folder1 /XD Folder2 /XD test /XD """instructie voor kandidaat"""
    robocopy `"c:\users\$user\downloads`" `"$backup_share_examen_azure\$today\$exam\$user\downloads`" /E /XO /XD Folder1 /XD Folder2 /XD test /XD """instructie voor kandidaat"""
    #robocopy `"c:\users\$user\destkop`" `"$backup_share_examen_azure\$user\desktop`" /E /XO /XD Folder1 /XD Folder2 /XD test /XD """instructie voor kandidaat"""
