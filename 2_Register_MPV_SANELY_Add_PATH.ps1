# ============================================================
# Register-MPV-Diagnostic.ps1
# With extra output to see what's really happening
# ============================================================

# Auto-elevate
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
    Write-Host "Not running as admin → requesting elevation..." -ForegroundColor Yellow
    Start-Process powershell.exe -Verb RunAs -ArgumentList @(
        "-NoProfile",
        "-ExecutionPolicy", "Bypass",
        "-File", "`"$PSCommandPath`""
    )
    exit
}

Write-Host "Running elevated as admin." -ForegroundColor Green

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Use PSScriptRoot instead of Get-Location (critical fix!)
$mpvDir = $PSScriptRoot
if (-not $mpvDir) {
    $mpvDir = Get-Location
    Write-Host "Warning: PSScriptRoot was empty, fell back to Get-Location" -ForegroundColor Yellow
}

$mpvExe = Join-Path $mpvDir "mpv.exe"

Write-Host "`n=== Diagnostic Info ===" -ForegroundColor Cyan
Write-Host "Script location (PSScriptRoot) : $PSScriptRoot"
Write-Host "Current directory (Get-Location): $(Get-Location)"
Write-Host "Resolved mpv directory          : $mpvDir"
Write-Host "Resolved mpv.exe path           : $mpvExe"
Write-Host "mpv.exe exists?                 : $(Test-Path $mpvExe)" -ForegroundColor $(if (Test-Path $mpvExe) {"Green"} else {"Red"})

if (-not (Test-Path $mpvExe)) {
    Write-Host "`n❌ ERROR: mpv.exe not found at the expected path!" -ForegroundColor Red
    Write-Host "   Make sure this script is in the same folder as mpv.exe"
    Write-Host "   Press Enter to exit..." -ForegroundColor White
    $null = Read-Host
    exit 1
}

Write-Host "`n🔧 Registering mpv.exe..." -ForegroundColor Cyan
Write-Host "Target directory: $mpvDir" -ForegroundColor DarkGray

# ------------------------------------------------------------
# App Paths
# ------------------------------------------------------------
$appPaths = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\mpv.exe"
Write-Host "Registering App Paths → $appPaths"
New-Item -Path $appPaths -Force | Out-Null
Set-ItemProperty -Path $appPaths -Name "(Default)" -Value $mpvExe
Set-ItemProperty -Path $appPaths -Name "Path" -Value $mpvDir
Write-Host "✔ App Paths registered" -ForegroundColor Green

# ------------------------------------------------------------
# Applications (Open With)
# ------------------------------------------------------------
$appKey = "HKLM:\SOFTWARE\Classes\Applications\mpv.exe"
Write-Host "Registering Open With → $appKey"
New-Item -Path $appKey -Force | Out-Null
Set-ItemProperty -Path $appKey -Name "FriendlyAppName" -Value "mpv media player"

$cmdKey = "$appKey\shell\open\command"
New-Item -Path $cmdKey -Force | Out-Null
Set-ItemProperty -Path $cmdKey -Name "(Default)" -Value "`"$mpvExe`" `"%1`""
Write-Host "✔ Open With support registered" -ForegroundColor Green

# ------------------------------------------------------------
# System PATH
# ------------------------------------------------------------
$envKey = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
$currentPath = (Get-ItemProperty $envKey -Name Path).Path

$mpvDirEscaped = [regex]::Escape($mpvDir)
if ($currentPath -notmatch $mpvDirEscaped) {
    Write-Host "Adding to PATH: $mpvDir"
    $newPath = "$currentPath;$mpvDir"
    Set-ItemProperty -Path $envKey -Name Path -Value $newPath
    Write-Host "✔ Added to system PATH" -ForegroundColor Green
} else {
    Write-Host "ℹ️ Already in PATH – no change needed" -ForegroundColor DarkGray
}

# ------------------------------------------------------------
# Summary & Pause
# ------------------------------------------------------------
Write-Host "`n=== Registration Complete ===" -ForegroundColor Cyan
Write-Host "mpv should now be launchable via Win+R → 'mpv'" -ForegroundColor White
Write-Host "For 'Open with' to appear reliably, you may still need to add SupportedTypes (optional next step)"
Write-Host "`nNote: New PATH only visible in new command prompts or after logoff/restart of explorer.exe"

Write-Host "`nPress Enter to close this window..." -ForegroundColor White
$null = Read-Host