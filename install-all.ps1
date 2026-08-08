# =============================================================================
# install-all.ps1
#
# Installs all DLibs JARs from the Libs-JARs repository into the local Maven
# repository (~/.m2/repository).
#
# This script is intended to be run from the root of the Libs-JARs repository.
#
# IMPORTANT: If you are on Windows and your PowerShell execution policy is set
# to Restricted (the default on many systems), this script cannot be run
# directly. Use the launcher script install-all.bat instead, which automatically
# bypasses the execution policy for this script.
#
# If you run this script directly on Windows and your PowerShell execution policy
# is set to Restricted, you must either:
#   - Run it with: powershell -ExecutionPolicy Bypass -File install-all.ps1
#   - Change your execution policy (not recommended for security reasons)
#
# Usage:
#   - From Windows GUI (recommended): double-click install-all.bat
#   - From Windows PowerShell (if policy allows): .\install-all.ps1
#   - From Windows GUI (if policy allows): right-click install-all.ps1 and
#     choose "Run with PowerShell".
# =============================================================================


# =============================================================================
# Configuration
# =============================================================================
$DLIBS_DIR = "dlibs"

# Color definitions
function Write-Success { Write-Host $args[0] -ForegroundColor Green }
function Write-Warning { Write-Host $args[0] -ForegroundColor Yellow }
function Write-Error { Write-Host $args[0] -ForegroundColor Red }
function Write-Info { Write-Host $args[0] -ForegroundColor Cyan }
function Write-Normal { Write-Host $args[0] -ForegroundColor White }

Write-Normal ""
Write-Normal "========================================"
Write-Normal "  Installing all DLibs to local Maven repo"
Write-Normal "========================================"
Write-Normal ""

# Check if dlibs directory exists
if (-not (Test-Path $DLIBS_DIR)) {
    Write-Error "ERROR: $DLIBS_DIR directory not found."
    Write-Normal "Please run this script from the root of the Libs-JARs repository."
    Read-Host "Press Enter to exit"
    exit 1
}

# Find all JAR files in dlibs directory
$jarFiles = Get-ChildItem -Path $DLIBS_DIR -Recurse -Filter "*.jar" -File

if ($jarFiles.Count -eq 0) {
    Write-Error "ERROR: No JAR files found in $DLIBS_DIR directory."
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
        Write-Warning ("WARNING: POM file not found for " + $jarFile.Name + ". Skipping.")
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
