#!/usr/bin/env bash
# install.sh - Install dok CLI
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🔧 dok CLI Installer"
echo ""

# Check if Deno is installed
if ! command -v deno &> /dev/null; then
    echo -e "${RED}Error: Deno is not installed${NC}"
    echo "Install Deno from: https://deno.land/manual/getting_started/installation"
    exit 1
fi

# Determine script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

echo -e "${YELLOW}Compiling dok...${NC}"
deno task compile

if [ ! -f "./dok" ]; then
    echo -e "${RED}Error: Compilation failed${NC}"
    exit 1
fi

# Install to /usr/local/bin
INSTALL_DIR="/usr/local/bin"
echo -e "${YELLOW}Installing to ${INSTALL_DIR}...${NC}"

if [ -w "$INSTALL_DIR" ]; then
    mv ./dok "$INSTALL_DIR/dok"
else
    echo "Requesting sudo privileges to install to ${INSTALL_DIR}"
    sudo mv ./dok "$INSTALL_DIR/dok"
fi

echo -e "${GREEN}✓ dok installed successfully!${NC}"
echo ""
echo "Usage:"
echo "  dok --help"
echo "  dok ps"
echo "  dok swarm"
echo "  dok svc <service>"
echo ""
echo -e "${YELLOW}Note:${NC} The compiled binary includes the Deno runtime and does not require Deno to be installed on the target system."

