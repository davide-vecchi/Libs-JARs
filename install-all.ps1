# =============================================================================
# install-all.ps1
#
# Installs all DLibs JARs from the Libs-JARs repository into the local Maven
# repository (~/.m2/repository).
#
# This script is intended to be run from the root of the Libs-JARs repository.
#
# Usage:
#   Right-click this file and select "Run with PowerShell", or
#   run from PowerShell: .\install-all.ps1
#   Or double-click install-all.bat
# =============================================================================

# Color definitions
function Write-Success { Write-Host $args[0] -ForegroundColor Green }
function Write-Warning { Write-Host $args[0] -ForegroundColor Yellow }
function Write-Error { Write-Host $args[0] -ForegroundColor Red }
function Write-Info { Write-Host $args[0] -ForegroundColor Cyan }
function Write-Normal { Write-Host $args[0] -ForegroundColor White }

Write-Normal ""
Write-Normal "=========================================="
Write-Normal "  Installing all DLibs to local Maven repo"
Write-Normal "=========================================="
Write-Normal ""

# Check if dlibs directory exists
if (-not (Test-Path "dlibs")) {
    Write-Error "ERROR: dlibs directory not found."
    Write-Normal "Please run this script from the root of the Libs-JARs repository."
    Read-Host "Press Enter to exit"
    exit 1
}

# Find all JAR files in dlibs directory
$jarFiles = Get-ChildItem -Path "dlibs" -Recurse -Filter "*.jar" -File

if ($jarFiles.Count -eq 0) {
    Write-Error "ERROR: No JAR files found in dlibs directory."
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Normal "Found $($jarFiles.Count) JAR file(s):"
foreach ($jarFile in $jarFiles) {
    Write-Normal "  $($jarFile.FullName)"
}
Write-Normal ""

$answer = Read-Host "Install all these JARs to local Maven repository? (y/n)"

if ($answer -ne 'y' -and $answer -ne 'Y') {
    Write-Normal "Aborted."
    exit 0
}

Write-Normal ""
Write-Normal "Installing JARs..."

$successCount = 0
$failCount = 0

foreach ($jarFile in $jarFiles) {
    $pomFile = [System.IO.Path]::ChangeExtension($jarFile.FullName, ".pom")
    
    if (-not (Test-Path $pomFile)) {
        Write-Warning "WARNING: POM file not found for $($jarFile.Name). Skipping."
        $failCount++
        continue
    }
    
    Write-Normal "  Installing: $($jarFile.Name)"
    
    & mvn install:install-file -Dfile="$($jarFile.FullName)" -DpomFile="$pomFile"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "  Success"
        $successCount++
    } else {
        Write-Error "  Failed"
        $failCount++
    }
    Write-Normal ""
}

Write-Normal ""
Write-Success "Installation complete."
Write-Normal "  Successful: $successCount"
Write-Error "  Failed: $failCount"
Read-Host "Press Enter to exit"
