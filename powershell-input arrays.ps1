function Get-IPs {
    $ips = @()
    $ipRegex = '^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\/([0-9]|[1-2][0-9]|3[0-2]))?$'

    while ($true) {
        $userInput = Read-Host "Enter an IP or CIDR (blank to end):"
        if ([string]::IsNullOrWhiteSpace($userInput)) {
            break
        }
        if ($userInput -match $ipRegex) {
            $ips += $userInput
        } else {
            Write-Host "Invalid IP or CIDR notation. Please try again."
        }
    }

    return $ips
}

function Get-Processes {
    $processes = @()
    $badProcesses = @()
    $processRegex = '^(?:[a-zA-Z]\:|\\\\[\w\.]+\\[\w.$]+)\\(?:[\w]+\\)*\w([\w.])+$'

    while ($true) {
        $userInput = Read-Host "Enter Path of process executable (eg. C:\hahahaha.exe, leave blank to end):"
        if ([string]::IsNullOrWhiteSpace($userInput)){
            break
        }
        if ($userInput -match $processRegex) {
            $processes += $userInput
        } else {
            Write-Host "Invalid file path. Please try again"
        }
    }

    foreach ($item in $processes) {
        $escapedItem = $item -replace '\\', '\\' -replace '\.', '\.'
        $badProcesses += "BadProcessFilter = {(`$_.CommandLine -match $escapedItem)}"
    } 

    return $badProcesses
}

function Get-Services {
    $services = @()
    $badServices = @()
    $serviceRegex = '^(?:[a-zA-Z]\:|\\\\[\w\.]+\\[\w.$]+)\\(?:[\w]+\\)*\w([\w.])+$'

    while ($true) {
        $userInput = Read-Host "Enter Path of service executable (eg. C:\hahahaha.exe, leave blank to end):"
        if ([string]::IsNullOrWhiteSpace($userInput)){
            break
        }
        if ($userInput -match $serviceRegex) {
            $services += $userInput
        } else {
            Write-Host "Invalid file path. Please try again"
        }
    }

    foreach ($item in $services) {
        $escapedItem = $item -replace '\\', '\\' -replace '\.', '\.'
        $serviceName = Read-Host "Enter the name of the service for $item (eg. hahahaha):"
        $badServices += "BadServiceFilter = {(($_.Name -match '$serviceName') -and ($_.PathName -match '$escapedItem'))}"
    } 

    return $badServices
}

function Get-Tasks {
    $tasks = @()
    $badTasks = @()
    $taskRegex = '^(?:[a-zA-Z]\:|\\\\[\w\.]+\\[\w.$]+)\\(?:[\w]+\\)*\w([\w.])+$'

    while ($true) {
        $userInput = Read-Host "Enter Path of task executable (eg. C:\hahahaha.exe, leave blank to end):"
        if ([string]::IsNullOrWhiteSpace($userInput)){
            break
        }
        if ($userInput -match $taskRegex) {
            $tasks += $userInput
        } else {
            Write-Host "Invalid file path. Please try again"
        }
    }

    foreach ($item in $tasks) {
        $escapedItem = $item -replace '\\', '\\' -replace '\.', '\.'
        $fileNameOnly = [System.IO.Path]::GetFileNameWithoutExtension($item)
        $taskName = Read-Host "Enter the name of the task for $item (eg. hahahaha):"
        $badTasks += "BadTaskFilter = {(($_.Name -eq '$taskName') -and ($_.Command -match '$fileNameOnly\.exe')) -or (($_.Name -eq '$taskName') -and ($_.Command -match '$escapedItem'))}"
    } 

    return $badTasks
}

function Get-Registrys {
    $registryItems = @()
    $badRegistryItems = @()
    $registryRegex = '^(?:HKLM|HKCU|HKCR|HKU|HKCC)\\(?:[\w]+\\)*\w([\w.])+$'
    while ($true) {
        $userInput = Read-Host "Enter Path of registry item (eg. HKLM\Software\Microsoft\Windows\CurrentVersion\Run, leave blank to end):"
        if ([string]::IsNullOrWhiteSpace($userInput)){
            break
        }
        if ($userInput -match $registryRegex) {
            $registryItems += $userInput
        } else {
            Write-Host "Invalid registry path. Please try again"
        }
    }

    foreach ($item in $registryItems) {
        $itemPath = $item
        $itemProperty = Read-Host "Enter the property name for $item (eg. Shell):"
        $item64Arch = [bool](Read-Host "Is this for 64-bit architecture? (True/False):")
        $item32Arch = [bool](Read-Host "Is this for 32-bit architecture? (True/False):")
        $itemRestore = [bool](Read-Host "Should this item be restored? (True/False):")
        $itemCorrectValue = Read-Host "Enter the correct value for $item (leave blank if not applicable):"
        $itemDelete = [bool](Read-Host "Should this item be deleted? (True/False):")
        $itemDataDelete = [bool](Read-Host "Should the data of this item be deleted? (True/False):")
        $itemDataMatch = Read-Host "Enter the data match for $item (leave blank if not applicable):"
        $itemKeyDelete = [bool](Read-Host "Should the key of this item be deleted? (True/False):")
        $itemPreserve = [bool](Read-Host "Should this item be preserved? (True/False):")
        $itemPreserveFile = Read-Host "Enter the file to preserve for $item (leave blank if not applicable):"
        $itemPreserveBin = Read-Host "Enter the binary to preserve for $item (leave blank if not applicable):"

        $badRegistryItems += New-Object psobject -Property @{
            ItemPath = $itemPath
            ItemProperty = $itemProperty
            Item64Arch = $item64Arch
            Item32Arch = $item32Arch
            ItemRestore = $itemRestore
            ItemCorrectValue = $itemCorrectValue
            ItemDelete = $itemDelete
            ItemDataDelete = $itemDataDelete
            ItemDataMatch = $itemDataMatch
            ItemKeyDelete = $itemKeyDelete
            ItemPreserve = $itemPreserve
            ItemPreserveFile = $itemPreserveFile
            ItemPreserveBin = $itemPreserveBin
        }
    } 

    return $badRegistryItems
}

# Usage example:
Get-IPs
Get-Processes
Get-Services
Get-Tasks
Get-Registrys

# function for malicious services
# function for scheduled tasks
# function for registry entries
# function for appcompat shims
# regex search for logs and malicious files
# specifically named malicious files
# specifically named malicious program installations(items that have installers)
# Archive of files that are to be preserved
# Matches for hashes on files
# Verbose logging to console
# Optionally naming LogDir, LogFilePath, LogFileName, LogFileFullPath,ZipFileName,ZipFilePath,ZipFileFullPath

