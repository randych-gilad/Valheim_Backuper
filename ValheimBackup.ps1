# Output is logged to nearby file with Write-Output
# Output of Folder creation cmdlet is nulled for reasons
# Logging is divided by launches and appends

# Define documents folder cuz I'm lazy
$Docs = "$env:USERPROFILE\Documents"

# Define screenshot folder, to purge
$Folder = "$env:USERPROFILE\AppData\LocalLow\"

# Defines base directory path
$BackupDir = "$Docs\ValheimBackups\"

# Defines current log file
$CurrentLog = "$Docs\ValheimBackupCurrent.log"

Write-Output "Backup creation: $(Get-Date -Format "yyyy.MM.dd HH:mm:ss")" >> $CurrentLog

# Create directory for backups if it doesn't exist
if (-not (Test-Path -Path $BackupDir)) {
    Write-Output "`nDirectory $BackupDir doesn't exist." >> $CurrentLog
    New-Item -ItemType Directory -Path "$BackupDir" | Out-Null
    Write-Output "`nCreated $BackupDir." >> $CurrentLog
    }

# Now make it have a cozy gear icon

$DesktopIni = @"
[.ShellClassInfo]
IconResource=C:\WINDOWS\System32\SHELL32.dll,316
"@

#Create/Add content to the desktop.ini file
Add-Content "$($BackupDir)\desktop.ini" -Value $DesktopIni
  
#Set the attributes for $DesktopIni
(Get-Item "$($BackupDir)\desktop.ini" -Force).Attributes = 'Hidden, System, Archive'
 
#Finally, set the Folder's attributes
(Get-Item $BackupDir -Force).Attributes = 'ReadOnly, Directory'

# Purge screenshots
if (Test-Path -Path "$Folder\IronGate\Valheim\screenshots\") {
    Remove-Item $Folder\IronGate\Valheim\screenshots\
    Write-Output "`nPurged screenshot folder before creating backup."  >> $CurrentLog
    }

# Compress worlds and characters
&Compress-Archive `
-Path $Folder\IronGate `
-DestinationPath "$BackupDir\$(Get-Date -Format "yyyy_MM_dd-HH_mm_ss")_Backup"
Write-Output "`nCreated $(Get-Date -Format "yyyy_MM_dd-HH_mm_ss")_Backup`n" >> $CurrentLog

# Defines how many files you want to keep
$Keep = 3

# Specifies file mask
$FileMask = "*.zip"

# Creates a full path plus file mask value
$FullPath = $BackupDir + $FileMask

# Creates an array of all files of a file type within a given Folder, reverse sort.
$AllFiles = @(Get-ChildItem $FullPath) | SORT Name -Descending 

# Checks to see if there is even $Keep files of the given type in the directory.
If ($AllFiles.count -gt $Keep) {

    # Creates a new array that specifies the files to delete, a bit ugly but concise.
    $DeleteFiles = $AllFiles[$($AllFiles.Count - ($AllFiles.Count - $Keep))..$AllFiles.Count]

    # Write about deletion

    Write-Output "There are more than $Keep backups. `nDeleting oldest backups." >> $CurrentLog

    # ForEach loop that goes through the DeleteFile array
    ForEach ($DeleteFile in $DeleteFiles) {

        # Creates a full path and delete file value
        $dFile = $BackupDir + $DeleteFile.Name

        # Deletes the specified file
        Remove-Item $dFile

        #Informs which files were deleted
		Write-Output "`nDeleted $($DeleteFile.Basename)" >> $CurrentLog
    }
}

# Mark an end of log entry
Write-Output $("-" * 36) >> $CurrentLog

# In case someone is running this from console and is lazy to open file
Get-Content $CurrentLog

# Check if log file was created
# Prepend current log to ongoing log

if (-not (Test-Path -Path $Docs\ValheimBackup.log)) {
    New-Item $Docs\ValheimBackup.log | Out-Null
    }

#Workaround to actually PREPEND
@($(Get-Content $CurrentLog) + $(Get-Content $Docs\ValheimBackup.log)) | Set-Content $Docs\ValheimBackup.log | Out-Null
Remove-Item $CurrentLog
