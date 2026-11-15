<#
.SYNOPSIS
    Packages the TomesGuard addon into a ZIP archive for ESOUI.
.DESCRIPTION
    Reads the addon manifest to detect version, stages files inside a root 'TomesGuard'
    folder, and generates a ZIP archive ready for upload to ESOUI.
#>
[CmdletBinding()]
param(
    [string]$OutputDir = ""
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($OutputDir)) {
    $OutputDir = Join-Path $PSScriptRoot "dist"
}

$addonName = "TomesGuard"
$manifestPath = Join-Path $PSScriptRoot "$addonName.txt"

if (-not (Test-Path $manifestPath)) {
    Write-Error "Manifest file not found: $manifestPath"
}

# Extract version from manifest
$version = "1.0.0"
$versionLine = Get-Content $manifestPath | Where-Object { $_ -match "^##\s*Version:\s*(.+)$" }
if ($versionLine -and $Matches[1]) {
    $version = $Matches[1].Trim()
}

Write-Host "Packaging $addonName v$version for ESOUI..." -ForegroundColor Cyan

# Ensure output directory exists
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

# Prepare temporary staging directory
$tempDir = Join-Path ([System.IO.Path]::GetTempPath()) "ESO_Build_$addonName"
if (Test-Path $tempDir) {
    Remove-Item -Path $tempDir -Recurse -Force
}

$stagedAddonDir = Join-Path $tempDir $addonName
New-Item -ItemType Directory -Path $stagedAddonDir -Force | Out-Null

# Files & folders to include in ESOUI distribution
$itemsToCopy = @(
    "$addonName.txt",
    "$addonName.lua",
    "lang"
)

foreach ($item in $itemsToCopy) {
    $sourcePath = Join-Path $PSScriptRoot $item
    if (Test-Path $sourcePath) {
        Copy-Item -Path $sourcePath -Destination $stagedAddonDir -Recurse -Force
    }
}

# Target ZIP files
$versionedZip = Join-Path $OutputDir "$addonName-v$version.zip"
$genericZip = Join-Path $OutputDir "$addonName.zip"

if (Test-Path $versionedZip) { Remove-Item -Path $versionedZip -Force }
if (Test-Path $genericZip) { Remove-Item -Path $genericZip -Force }

# Compress staged folder (ensures root folder inside ZIP is TomesGuard/)
Compress-Archive -Path $stagedAddonDir -DestinationPath $versionedZip -Force
Copy-Item -Path $versionedZip -Destination $genericZip -Force

# Clean up temporary staging directory
Remove-Item -Path $tempDir -Recurse -Force

Write-Host "`nCreated ESOUI package successfully:" -ForegroundColor Green
Write-Host "  -> $versionedZip" -ForegroundColor Yellow
Write-Host "  -> $genericZip" -ForegroundColor Yellow

# Verify archive internal structure
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::OpenRead($versionedZip)
Write-Host "`nArchive contents:" -ForegroundColor Cyan
foreach ($entry in $zip.Entries) {
    Write-Host "  $($entry.FullName)" -ForegroundColor Gray
}
$zip.Dispose()
