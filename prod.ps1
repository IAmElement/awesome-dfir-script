# Stage A: Pulls all recently logged in users
Start-Sleep -Seconds 2
Write-Output "Starting Stage A: Pulling all recently logged in users..."
Get-EventLog -LogName Security | Where-Object {$_.EventID -eq 4624} | Select-Object TimeGenerated, UserName, IPAddress, Message | Export-Csv -Path "RecentlyLoggedInUsers.csv" -NoTypeInformation
Write-Output "Finished Stage A: All recently logged in users have been pulled."

# Stage B: Pulls all recent network connections
Start-Sleep -Seconds 2
Write-Output "Starting Stage B: Pulling all recent network connections..."
Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Where-Object {$_.IPAddress} | Select-Object ServiceName, SettingID, Description, DHCPEnabled, IPAddress, MACAddress | Export-Csv -Path "RecentNetworkConnections.csv" -NoTypeInformation
Write-Output "Finished Stage B: All recent network connections have been pulled."

# Stage C: Pulls all processes for all users
Start-Sleep -Seconds 2
Write-Output "Starting Stage C: Pulling all processes for all users..."
Get-Process | Select-Object ProcessName, UserName, SessionId, Path, StartTime, FileVersion | Export-Csv -Path "AllProcesses.csv" -NoTypeInformation
Write-Output "Finished Stage C: All processes for all users have been pulled."

# Stage D: Pulls recently deleted items
Start-Sleep -Seconds 2
Write-Output "Starting Stage D: Pulling recently deleted items..."
Get-EventLog -LogName Application | Where-Object {$_.EventID -eq 104} | Select-Object TimeGenerated, UserName, Message | Export-Csv -Path "RecentlyDeletedItems.csv" -NoTypeInformation
Write-Output "Finished Stage D: All recently deleted items have been pulled."

# Stage E: Grabs all contents of all users Downloads folders and takes a SHA-256 hash
Start-Sleep -Seconds 2
Write-Output "Starting Stage E: Grabbing all contents of all users Downloads folders and taking a SHA-256 hash..."
$downloadFolders = Get-ChildItem -Path "C:\Users" -Directory | Where-Object { $_.Name -eq "Downloads" } | Select-Object FullName
foreach ($folder in $downloadFolders) {
  Get-ChildItem -Path $folder.FullName | ForEach-Object {
    $sha256 = (Get-FileHash $_.FullName -Algorithm SHA256).Hash
    $created = $_.CreationTime
    $modified = $_.LastWriteTime
    $accessed = $_.LastAccessTime
    New-Object PSObject -Property @{
      "FileName" = $_.Name
      "FilePath" = $_.FullName
      "SHA256" = $sha256
      "CreationTime" = $created
      "LastWriteTime" = $modified
      "LastAccessTime" = $accessed
    }
  } | Export-Csv -Path "DownloadsHash.csv" -Append -NoTypeInformation
}
Write-Output "Finished Stage E: All contents of all users Downloads folders have been grabbed and a SHA-256 hash has been collected."


# Stage F: Collect basic system information
Start-Sleep -Seconds 2
Write-Output "Starting Stage F: Collecting basic system information..."
Get-WmiObject -Class Win32_OperatingSystem | Select-Object Caption, Version, BuildNumber, OSArchitecture, RegisteredUser, SystemDrive, TotalVirtualMemorySize, TotalVisibleMemorySize | Export-Csv -Path "SystemInformation.csv" -NoTypeInformation
Write-Output "Finished Stage F: All system information has been collected."


# Stage G: Pull Event IDs 4719, 4964, 4720, and 4728
Start-Sleep -Seconds 2
Write-Output "Starting Stage G: Collecting event logs pertaining to event IDs 4719, 4964, 4720 and 4728..."
Get-EventLog -LogName Security | Where-Object {$_.EventID -in @(4719, 4964, 4720, 4728)} | Select-Object TimeGenerated, EventID, UserName, Message | Export-Csv -Path "ImportantEventIDs.csv" -NoTypeInformation
Write-Output "Finished Stage G: The specified event IDs have been collected."

# Stage H: Check for recent removable devices
Start-Sleep -Seconds 2
Write-Output "Starting Stage H: Checking for recent removable media..."
Get-WmiObject -Class Win32_Volume | Where-Object {$_.DriveType -eq 2} | Select-Object Name, Label, DriveLetter, Capacity, FreeSpace | Export-Csv -Path "RecentRemovableDevices.csv" -NoTypeInformation
Write-Output "Finished Stage H: Collected information of recent removable media..."

Write-Output "====================================================="
Write-Output "Collection of important DFIR artifacts has finished. Please see the provided CSV files in the working directory..."
Start-Sleep -Seconds 100


