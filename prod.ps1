# A) Pulls all recently logged in users
Get-EventLog -LogName Security | Where-Object {$_.EventID -eq 4624} | Select-Object TimeGenerated, UserName, IPAddress, Message | Export-Csv -Path "RecentlyLoggedInUsers.csv" -NoTypeInformation

# B) Pulls all recent network connections
Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Where-Object {$_.IPAddress} | Select-Object ServiceName, SettingID, Description, DHCPEnabled, IPAddress, MACAddress | Export-Csv -Path "RecentNetworkConnections.csv" -NoTypeInformation

# C) Pulls all processes for all users
Get-Process | Select-Object ProcessName, UserName, SessionId, Path, StartTime, FileVersion | Export-Csv -Path "AllProcesses.csv" -NoTypeInformation

# D) Pulls recently deleted items
Get-EventLog -LogName Application | Where-Object {$_.EventID -eq 104} | Select-Object TimeGenerated, UserName, Message | Export-Csv -Path "RecentlyDeletedItems.csv" -NoTypeInformation

# E) Grabs all contents of all users Downloads folders and takes a SHA-256 hash
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

# F) Collect basic system information
Get-WmiObject -Class Win32_OperatingSystem | Select-Object Caption, Version, BuildNumber, OSArchitecture, RegisteredUser, SystemDrive, TotalVirtualMemorySize, TotalVisibleMemorySize | Export-Csv -Path "SystemInformation.csv" -NoTypeInformation

# G) Pull Event IDs 4719, 4964, 4720, and 4728
Get-EventLog -LogName Security | Where-Object {$_.EventID -in @(4719, 4964, 4720, 4728)} | Select-Object TimeGenerated, EventID, UserName, Message | Export-Csv -Path "ImportantEventIDs.csv" -NoTypeInformation
