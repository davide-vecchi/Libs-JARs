#!/bin/bash

# =============================================================================
# install-all-dlibs.sh
#
# Installs all the library JARs from the Libs-JARs repository into the local
# Maven repository (~/.m2/repository).
#
# This script is the Unix counterpart to install-all-dlibs.ps1. It contains the
# installation logic directly, without needing a launcher, because Unix-like
# systems do not have a PowerShell execution policy.
#
# This script is intended to be run from the root of the Libs-JARs repository.
#
# Usage (from any terminal):
#   - Linux / macOS / Git Bash on Windows: ./install-all-dlibs.sh
# =============================================================================

set -e

# =============================================================================
# Configuration
# =============================================================================
DLIBS_DIR="dlibs"

# Color definitions
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

echo ""
echo "========================================"
echo "  Installing all DLibs to local Maven repo"
echo "========================================"
echo ""

# Check if dlibs directory exists
if [ ! -d "$DLIBS_DIR" ]; then
    echo -e "${RED}ERROR: $DLIBS_DIR directory not found.${NC}"
    echo "Please run this script from the root of the Libs-JARs repository."
    exit 1
fi

# Find all JAR files in dlibs directory
jar_files=$(find "$DLIBS_DIR" -name "*.jar" -type f)

if [ -z "$jar_files" ]; then
    echo -e "${RED}ERROR: No JAR files found in $DLIBS_DIR directory.${NC}"
    exit 1
fi

echo "Found the following JAR files:"
echo "$jar_files"
echo ""

read -r -p "Install all these JARs to local Maven repository? (y/n): " answer

if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
    echo "Aborted."
    exit 0
fi

echo ""
echo "Installing JARs..."

for jar_file in $jar_files; do
    # Find the corresponding POM file (same name, .pom extension)
    pom_file="${jar_file%.jar}.pom"

    if [ ! -f "$pom_file" ]; then
        echo -e "${YELLOW}WARNING: POM file not found for $jar_file. Skipping.${NC}"
        continue
    fi

    echo "  Installing: $jar_file"
    if mvn install:install-file -Dfile="$jar_file" -DpomFile="$pom_file"; then
        echo -e "${GREEN}  Success${NC}"
    else
        echo -e "${RED}  Failed${NC}"
    fi
    echo ""
done

echo -e "${GREEN}Installation complete.${NC}"
