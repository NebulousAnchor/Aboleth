Add-Type -AssemblyName System.Windows.Forms

function Show-InputBox {
    param (
        [string]$message,
        [string]$title
    )

    $form = New-Object System.Windows.Forms.Form
    $form.Text = $title
    $form.Width = 400
    $form.Height = 150

    $label = New-Object System.Windows.Forms.Label
    $label.Text = $message
    $label.AutoSize = $true
    $label.Top = 20
    $label.Left = 10
    $form.Controls.Add($label)

    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Width = 350
    $textBox.Top = 50
    $textBox.Left = 10
    $form.Controls.Add($textBox)

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Text = "OK"
    $okButton.Top = 80
    $okButton.Left = 10
    $okButton.Add_Click({ $form.DialogResult = [System.Windows.Forms.DialogResult]::OK })
    $form.Controls.Add($okButton)

    $form.AcceptButton = $okButton

    if ($form.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        return $textBox.Text
    } else {
        return ""
    }
}

function Get-IPs {
    $ips = @()
    $ipRegex = '^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\/([0-9]|[1-2][0-9]|3[0-2]))?$'
    while ($true) {
        $userInput = Show-InputBox -message "Enter an IP or CIDR (blank to end):" -title "IP Input"
        if ([string]::IsNullOrWhiteSpace($userInput)) {
            break
        }
        if ($userInput -match $ipRegex) {
            $ips += $userInput
        } else {
            [System.Windows.Forms.MessageBox]::Show("Invalid IP or CIDR notation. Please try again.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    }
    return $ips
}

function Get-Processes {
    $processes = @()
    $badProcesses = @()
    $processRegex = '^(?:[a-zA-Z]\:|\\\\[\w\.]+\\[\w.$]+)\\(?:[\w]+\\)*\w([\w.])+$'
    while ($true) {
        $userInput = Show-InputBox -message "Enter Path of process executable (eg. C:\hahahaha.exe, leave blank to end):" -title "Process Input"
        if ([string]::IsNullOrWhiteSpace($userInput)){
            break
        }
        if ($userInput -match $processRegex) {
            $processes += $userInput
        } else {
            [System.Windows.Forms.MessageBox]::Show("Invalid file path. Please try again.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
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
        $userInput = Show-InputBox -message "Enter Path of service executable (eg. C:\hahahaha.exe, leave blank to end):" -title "Service Input"
        if ([string]::IsNullOrWhiteSpace($userInput)){
            break
        }
        if ($userInput -match $serviceRegex) {
            $services += $userInput
        } else {
            [System.Windows.Forms.MessageBox]::Show("Invalid file path. Please try again.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    }
    foreach ($item in $services) {
        $escapedItem = $item -replace '\\', '\\' -replace '\.', '\.'
        $serviceName = Show-InputBox -message "Enter the name of the service for $item (eg. hahahaha):" -title "Service Name Input"
        $badServices += "BadServiceFilter = {(($_.Name -match '$serviceName') -and ($_.PathName -match '$escapedItem'))}"
    } 
    return $badServices
}

function Get-Tasks {
    $tasks = @()
    $badTasks = @()
    $taskRegex = '^(?:[a-zA-Z]\:|\\\\[\w\.]+\\[\w.$]+)\\(?:[\w]+\\)*\w([\w.])+$'
    while ($true) {
        $userInput = Show-InputBox -message "Enter Path of task executable (eg. C:\hahahaha.exe, leave blank to end):" -title "Task Input"
        if ([string]::IsNullOrWhiteSpace($userInput)){
            break
        }
        if ($userInput -match $taskRegex) {
            $tasks += $userInput
        } else {
            [System.Windows.Forms.MessageBox]::Show("Invalid file path. Please try again.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    }
    foreach ($item in $tasks) {
        $escapedItem = $item -replace '\\', '\\' -replace '\.', '\.'
        $fileNameOnly = [System.IO.Path]::GetFileNameWithoutExtension($item)
        $taskName = Show-InputBox -message "Enter the name of the task for $item (eg. hahahaha):" -title "Task Name Input"
        $badTasks += "BadTaskFilter = {(($_.Name -eq '$taskName') -and ($_.Command -match '$fileNameOnly\.exe')) -or (($_.Name -eq '$taskName') -and ($_.Command -match '$escapedItem'))}"
    } 
    return $badTasks
}

function Get-Registrys {
    $registryItems = @()
    $badRegistryItems = @()
    $registryRegex = '^(?:HKLM|HKCU|HKCR|HKU|HKCC)\\(?:[\w]+\\)*\w([\w.])+$'
    while ($true) {
        $userInput = Show-InputBox -message "Enter Path of registry item (eg. HKLM\Software\Microsoft\Windows\CurrentVersion\Run, leave blank to end):" -title "Registry Input"
        if ([string]::IsNullOrWhiteSpace($userInput)){
            break
        }
        if ($userInput -match $registryRegex) {
            $registryItems += $userInput
        } else {
            [System.Windows.Forms.MessageBox]::Show("Invalid registry path. Please try again.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    }
    foreach ($item in $registryItems) {
        $itemPath = $item
        $itemProperty = Show-InputBox -message "Enter the property name for $item (eg. Shell):" -title "Registry Property Input"
        $item64Arch = [bool](Show-InputBox -message "Is this for 64-bit architecture? (True/False):" -title "Architecture Input")
        $item32Arch = [bool](Show-InputBox -message "Is this for 32-bit architecture? (True/False):" -title "Architecture Input")
        $itemRestore = [bool](Show-InputBox -message "Should this item be restored? (True/False):" -title "Restore Input")
        $itemCorrectValue = Show-InputBox -message "Enter the correct value for $item (leave blank if not applicable):" -title "Correct Value Input"
        $itemDelete = [bool](Show-InputBox -message "Should this item be deleted? (True/False):" -title "Delete Input")
        $itemDataDelete = [bool](Show-InputBox -message "Should the data of this item be deleted? (True/False):" -title "Data Delete Input")
        $itemDataMatch = Show-InputBox -message "Enter the data match for $item (leave blank if not applicable):" -title "Data Match Input"
        $itemKeyDelete = [bool](Show-InputBox -message "Should the key of this item be deleted? (True/False):" -title "Key Delete Input")
        $itemPreserve = [bool](Show-InputBox -message "Should this item be preserved? (True/False):" -title "Preserve Input")
        $itemPreserveFile = Show-InputBox -message "Enter the file to preserve for $item (leave blank if not applicable):" -title "Preserve File Input"
        $itemPreserveBin = Show-InputBox -message "Enter the binary to preserve for $item (leave blank if not applicable):" -title "Preserve Bin Input"
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