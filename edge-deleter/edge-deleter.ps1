# === Administrator Rights Check ===
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "ERROR: This script must be run with administrator rights!" -ForegroundColor Red
    Read-Host "Press Enter to exit..."
    exit
}

Write-Host "----------------------------------------------------" -ForegroundColor Yellow
Write-Host "   Edge Vanisher: Permanent Uninstallation Tool" -ForegroundColor Yellow
Write-Host "----------------------------------------------------" -ForegroundColor Yellow

# 1. Terminate Edge Processes
Write-Host "[1/7] Terminating Edge processes..." -ForegroundColor Cyan
$processes = Get-Process | Where-Object { $_.Name -like "*edge*" }
if ($processes) {
    $processes | Stop-Process -Force -ErrorAction SilentlyContinue
    Write-Host "Successfully stopped all Edge processes." -ForegroundColor Green
} else {
    Write-Host "No running Edge processes found." -ForegroundColor Gray
}

# 2. Uninstall Edge via Setup.exe
Write-Host "[2/7] Searching for Edge Installer..." -ForegroundColor Cyan
$edgePath = Get-ChildItem -Path "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\*\Installer\setup.exe" -ErrorAction SilentlyContinue
if ($edgePath) {
    Write-Host "Installer found. Running force-uninstall..." -ForegroundColor Yellow
    Start-Process -FilePath $edgePath.FullName -ArgumentList "--uninstall --system-level --verbose-logging --force-uninstall" -Wait
    Write-Host "Official uninstaller command executed." -ForegroundColor Green
}

# 3. Remove Start Menu & Desktop Shortcuts
Write-Host "[3/7] Cleaning up shortcuts..." -ForegroundColor Cyan
$shortcuts = @(
    "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk",
    "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk",
    "$env:PUBLIC\Desktop\Microsoft Edge.lnk"
)
foreach ($path in $shortcuts) {
    if (Test-Path $path) {
        Remove-Item -Path $path -Force -ErrorAction SilentlyContinue
        Write-Host "Deleted shortcut: $path" -ForegroundColor Green
    }
}

# 4. Clean Edge Registry Keys
Write-Host "[4/7] Cleaning Registry entries..." -ForegroundColor Cyan
$edgeRegKeys = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge Update",
    "HKLM:\SOFTWARE\Microsoft\EdgeUpdate",
    "HKCU:\Software\Microsoft\Edge",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\msedge.exe",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Edge",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate"
)
foreach ($key in $edgeRegKeys) {
    if (Test-Path $key) {
        Remove-Item -Path $key -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Removed Key: $key" -ForegroundColor Green
    }
}

# 5. Remove EdgeUpdate Services
Write-Host "[5/7] Deleting Edge services..." -ForegroundColor Cyan
$services = @("edgeupdate", "edgeupdatem", "MicrosoftEdgeElevationService")
foreach ($service in $services) {
    if (Get-Service -Name $service -ErrorAction SilentlyContinue) {
        Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
        & sc.exe delete $service | Out-Null
        Write-Host "Service '$service' deleted." -ForegroundColor Green
    }
}

# 6. Restart Explorer (Refreshes the Taskbar/Start Menu)
Write-Host "[6/7] Refreshing Windows Explorer..." -ForegroundColor Cyan
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
Start-Process explorer

# 7. Create Protective "Vaccine" Folders
Write-Host "[7/7] Locking Edge folders to prevent re-install..." -ForegroundColor Cyan
$protectiveFolders = @(
    "${env:ProgramFiles(x86)}\Microsoft\Edge",
    "${env:ProgramFiles(x86)}\Microsoft\EdgeCore"
)

$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$systemSid = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-18") # SYSTEM
$adminsSid = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-32-544") # Administrators

foreach ($folder in $protectiveFolders) {
    if (-not (Test-Path $folder)) { New-Item -Path $folder -ItemType Directory -Force | Out-Null }
    
    try {
        $acl = Get-Acl $folder
        $acl.SetOwner([System.Security.Principal.NTAccount]$currentUser)
        $acl.SetAccessRuleProtection($true, $false) # Disable inheritance
        
        # Deny Rule for System/Admins to prevent writing to this folder
        $denyRule = New-Object System.Security.AccessControl.FileSystemAccessRule($systemSid, "FullControl", "ContainerInherit,ObjectInherit", "None", "Deny")
        $acl.AddAccessRule($denyRule)
        
        Set-Acl $folder $acl
        Write-Host "Folder $folder is now LOCKED." -ForegroundColor Green
    } catch {
        Write-Host "Could not lock $folder (already locked or in use)." -ForegroundColor Gray
    }
}

Write-Host "`nDONE! Microsoft Edge has been vanished." -ForegroundColor Green
Read-Host "Press Enter to exit..."