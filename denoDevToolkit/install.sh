#!/usr/bin/env bash
# install.sh - Install dok CLI
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# GitHub repository info
GITHUB_BASE_URL="https://raw.githubusercontent.com/Kiri23/dev-toolkit/main/denoDevToolkit"

echo "🔧 dok CLI Installer"
echo ""

# Determine script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Check if Deno is installed
if command -v deno &> /dev/null; then
    echo -e "${GREEN}✓ Deno found${NC}"
    echo -e "${YELLOW}Compiling dok from source...${NC}"
    
    cd "$SCRIPT_DIR"
    deno task compile
    
    if [ ! -f "./dok" ]; then
        echo -e "${RED}Error: Compilation failed${NC}"
        exit 1
    fi
    
    BINARY_PATH="./dok"
else
    echo -e "${YELLOW}⚠ Deno not found${NC}"
    echo -e "${BLUE}Downloading precompiled binary from GitHub...${NC}"
    
    # Detect OS and architecture
    OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    ARCH=$(uname -m)
    
    # Normalize architecture names
    case "$ARCH" in
        x86_64|amd64)
            ARCH="x64"
            ;;
        aarch64|arm64)
            ARCH="arm64"
            ;;
        *)
            echo -e "${RED}Error: Unsupported architecture: $ARCH${NC}"
            echo "Supported architectures: x86_64, amd64, aarch64, arm64"
            exit 1
            ;;
    esac
    
    # Normalize OS names
    case "$OS" in
        linux)
            OS="linux"
            ;;
        darwin)
            OS="darwin"
            ;;
        *)
            echo -e "${RED}Error: Unsupported OS: $OS${NC}"
            echo "Supported OS: Linux, macOS (Darwin)"
            exit 1
            ;;
    esac
    
    BINARY_NAME="dok-${OS}-${ARCH}"
    GITHUB_RAW_URL="${GITHUB_BASE_URL}/${BINARY_NAME}"
    
    echo -e "${BLUE}Detected: ${OS} ${ARCH}${NC}"
    echo -e "${BLUE}Downloading: ${BINARY_NAME}${NC}"
    
    # Create temporary file
    TEMP_DOK="/tmp/dok_download"
    
    # Download the precompiled binary
    if curl -fsSL "$GITHUB_RAW_URL" -o "$TEMP_DOK"; then
        chmod +x "$TEMP_DOK"
        BINARY_PATH="$TEMP_DOK"
        echo -e "${GREEN}✓ Binary downloaded successfully${NC}"
    else
        echo -e "${RED}Error: Failed to download binary from GitHub${NC}"
        echo "URL: $GITHUB_RAW_URL"
        echo ""
        echo "Please ensure the precompiled binary exists in the repository:"
        echo "  ${BINARY_NAME}"
        exit 1
    fi
fi

# Install to /usr/local/bin
INSTALL_DIR="/usr/local/bin"
echo -e "${YELLOW}Installing to ${INSTALL_DIR}...${NC}"

if [ -w "$INSTALL_DIR" ]; then
    mv "$BINARY_PATH" "$INSTALL_DIR/dok"
else
    echo "Requesting sudo privileges to install to ${INSTALL_DIR}"
    sudo mv "$BINARY_PATH" "$INSTALL_DIR/dok"
fi

echo ""
echo -e "${GREEN}✓ dok installed successfully!${NC}"
echo ""
echo "Usage:"
echo "  dok --help"
echo "  dok ps"
echo "  dok swarm"
echo "  dok svc <service>"
echo ""
echo -e "${YELLOW}Note:${NC} The compiled binary includes the Deno runtime and does not require Deno to be installed on the target system."