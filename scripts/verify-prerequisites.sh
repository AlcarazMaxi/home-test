#!/bin/bash
# Shell script to verify all prerequisites are installed
# Usage: ./scripts/verify-prerequisites.sh

echo "========================================"
echo "QA Automation Prerequisites Checker"
echo "========================================"
echo ""

all_good=true

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check Git
echo -n "Checking Git..."
if command_exists git; then
    git_version=$(git --version)
    echo " ✓ PASS"
    echo "  Version: $git_version"
else
    echo " ✗ FAIL"
    echo "  Install (macOS): brew install git"
    echo "  Install (Ubuntu): sudo apt install git"
    echo "  Install (Fedora): sudo dnf install git"
    all_good=false
fi
echo ""

# Check Node.js
echo -n "Checking Node.js..."
if command_exists node; then
    node_version=$(node -v)
    echo " ✓ PASS"
    echo "  Version: $node_version"
    if command_exists npm; then
        npm_version=$(npm -v)
        echo "  npm Version: $npm_version"
    fi
else
    echo " ✗ FAIL"
    echo "  Install (macOS): brew install node@20"
    echo "  Install (Ubuntu): curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - && sudo apt-get install -y nodejs"
    echo "  Install (Fedora): curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash - && sudo dnf install nodejs -y"
    all_good=false
fi
echo ""

# Check Java
echo -n "Checking Java..."
if command_exists java; then
    java_version=$(java -version 2>&1 | head -n 1)
    echo " ✓ PASS"
    echo "  Version: $java_version"
else
    echo " ✗ FAIL"
    echo "  Install (macOS): brew install openjdk@17"
    echo "  Install (Ubuntu): sudo apt install openjdk-17-jdk"
    echo "  Install (Fedora): sudo dnf install java-17-openjdk-devel"
    all_good=false
fi
echo ""

# Check Maven
echo -n "Checking Maven..."
if command_exists mvn; then
    mvn_version=$(mvn -v | head -n 1)
    echo " ✓ PASS"
    echo "  Version: $mvn_version"
else
    echo " ✗ FAIL"
    echo "  Install (macOS): brew install maven"
    echo "  Install (Ubuntu): sudo apt install maven"
    echo "  Install (Fedora): sudo dnf install maven"
    all_good=false
fi
echo ""

# Check Docker
echo -n "Checking Docker..."
if command_exists docker; then
    docker_version=$(docker --version)
    echo " ✓ PASS"
    echo "  Version: $docker_version"
    
    # Check if Docker daemon is running
    if docker ps >/dev/null 2>&1; then
        echo "  Docker daemon: Running ✓"
    else
        echo "  Docker daemon: Not running ✗"
        if [[ "$OSTYPE" == "darwin"* ]]; then
            echo "  Action: Open Docker Desktop app"
        else
            echo "  Action: sudo systemctl start docker"
        fi
    fi
else
    echo " ✗ FAIL"
    echo "  Install (macOS): brew install --cask docker"
    echo "  Install (Ubuntu): sudo apt install docker.io"
    echo "  Install (Fedora): sudo dnf install docker"
    all_good=false
fi
echo ""

# Check ripgrep
echo -n "Checking ripgrep..."
if command_exists rg; then
    rg_version=$(rg --version | head -n 1)
    echo " ✓ PASS"
    echo "  Version: $rg_version"
else
    echo " ✗ FAIL"
    echo "  Install (macOS): brew install ripgrep"
    echo "  Install (Ubuntu): sudo apt install ripgrep"
    echo "  Install (Fedora): sudo dnf install ripgrep"
    all_good=false
fi
echo ""

# Check cspell
echo -n "Checking cspell..."
if command_exists npx; then
    if cspell_version=$(npx cspell --version 2>&1); then
        echo " ✓ PASS"
        echo "  Version: $cspell_version"
    else
        echo " ✗ FAIL"
        echo "  Install: npm install -g cspell"
        all_good=false
    fi
else
    echo " ✗ FAIL"
    echo "  Install Node.js first"
    all_good=false
fi
echo ""

# Check Playwright (optional, but helpful)
echo -n "Checking Playwright (optional)..."
if command_exists npx; then
    if playwright_version=$(npx playwright --version 2>&1); then
        echo " ✓ PASS"
        echo "  Version: $playwright_version"
    else
        echo " ⚠ NOT FOUND"
        echo "  Install: cd ui-tests && npm install && npx playwright install"
    fi
else
    echo " ⚠ SKIP"
fi
echo ""

# Summary
echo "========================================"
if [ "$all_good" = true ]; then
    echo "✓ All prerequisites are installed!"
    echo "You're ready to run the tests."
else
    echo "✗ Some prerequisites are missing."
    echo "Please install the missing tools using the commands above."
fi
echo "========================================"
echo ""

# Exit with appropriate code
if [ "$all_good" = true ]; then
    exit 0
else
    exit 1
fi

