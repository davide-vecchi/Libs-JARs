#!/bin/bash

# =============================================================================
# install-all.sh
#
# Installs all DLibs JARs from the Libs-JARs repository into the local Maven
# repository (~/.m2/repository).
#
# This script is intended to be run from the root of the Libs-JARs repository.
#
# Usage (from Git Bash):
#
#   ./install-all.sh
#
# =============================================================================

set -e

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
if [ ! -d "dlibs" ]; then
    echo -e "${RED}ERROR: dlibs directory not found.${NC}"
    echo "Please run this script from the root of the Libs-JARs repository."
    exit 1
fi

# Find all JAR files in dlibs directory
jar_files=$(find dlibs -name "*.jar" -type f)

if [ -z "$jar_files" ]; then
    echo -e "${RED}ERROR: No JAR files found in dlibs directory.${NC}"
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
    mvn install:install-file -Dfile="$jar_file" -DpomFile="$pom_file"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}  Success${NC}"
    else
        echo -e "${RED}  Failed${NC}"
    fi
    echo ""
done

echo -e "${GREEN}Installation complete.${NC}"
