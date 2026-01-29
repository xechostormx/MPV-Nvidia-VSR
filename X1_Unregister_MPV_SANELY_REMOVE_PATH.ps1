# ============================================================
# Unregister-MPV.ps1
# Removes PATH and shell visibility
# No prompts. Shows diagnostics. Auto-closes after pause.
# ============================================================

# Auto-elevate if needed
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

# Use PSScriptRoot (same as register script)
$mpvDir = $PSScriptRoot
if (-not $mpvDir) {
    $mpvDir = Get-Location
    Write-Host "Warning: PSScriptRoot was empty, fell back to Get-Location" -ForegroundColor Yellow
}

Write-Host "`n=== Diagnostic Info ===" -ForegroundColor Cyan
Write-Host "Script location (PSScriptRoot) : $PSScriptRoot"
Write-Host "Current directory (Get-Location): $(Get-Location)"
Write-Host "Resolved mpv directory          : $mpvDir"

Write-Host "`n🧹 Unregistering MPV system integration..." -ForegroundColor Cyan
Write-Host "Target directory being removed: $mpvDir" -ForegroundColor DarkGray

# ------------------------------------------------------------
# Remove App Paths
# ------------------------------------------------------------
$appPaths = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\mpv.exe"
Write-Host "Removing App Paths → $appPaths"
Remove-Item $appPaths -Recurse -Force -ErrorAction Ignore
Write-Host "✔ Removed App Paths entry (or already gone)" -ForegroundColor Green

# ------------------------------------------------------------
# Remove Open With registration
# ------------------------------------------------------------
$appKey = "HKLM:\SOFTWARE\Classes\Applications\mpv.exe"
Write-Host "Removing Open With → $appKey"
Remove-Item $appKey -Recurse -Force -ErrorAction Ignore
Write-Host "✔ Removed Open With registration (or already gone)" -ForegroundColor Green

# ------------------------------------------------------------
# Remove from system PATH
# ------------------------------------------------------------
$envKey = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
try {
    $currentPath = (Get-ItemProperty $envKey -Name Path -ErrorAction Stop).Path
    $mpvDirEscaped = [regex]::Escape($mpvDir)

    if ($currentPath -match $mpvDirEscaped) {
        Write-Host "Removing from PATH: $mpvDir"
        $newPath = ($currentPath -split ';' | Where-Object { $_ -notmatch "^$mpvDirEscaped$" -and $_ -ne '' }) -join ';'
        Set-ItemProperty -Path $envKey -Name Path -Value $newPath
        Write-Host "✔ Removed MPV directory from system PATH" -ForegroundColor Green
    } else {
        Write-Host "ℹ️  Directory not found in PATH – no change needed" -ForegroundColor DarkGray
    }
}
catch {
    Write-Host "⚠️  Could not read/modify system PATH: $($_.Exception.Message)" -ForegroundColor Yellow
}

# ------------------------------------------------------------
# Summary & Pause
# ------------------------------------------------------------
Write-Host "`n=== Unregistration Complete ===" -ForegroundColor Cyan
Write-Host "mpv.exe integration removed from Win+R and Open With menus" -ForegroundColor White
Write-Host "Note: PATH change only takes effect in new command prompts or after logoff/restart of explorer.exe"

Write-Host "`nPress Enter to close this window..." -ForegroundColor White
$null = Read-Host