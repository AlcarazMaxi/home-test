# Installation Guide — Step-by-Step for Beginners

## Overview

This guide walks you through installing all prerequisites to run the UI and API automation tests on **Windows**, **macOS**, or **Linux**.

## Choose Your Operating System

- [Windows Installation](#windows-installation)
- [macOS Installation](#macos-installation)
- [Linux Installation (Ubuntu/Debian)](#linux-installation-ubuntudebian)
- [Linux Installation (Fedora/RHEL)](#linux-installation-fedorarhel)

---

## Windows Installation

### Step 1: Install Git

**WHAT**: Version control system  
**WHY**: Clone the project repository

**HOW**:
1. Open **PowerShell as Administrator** (Right-click Start → Windows PowerShell (Admin))
2. Run: `winget install Git.Git`
3. Close and reopen PowerShell

**VERIFY**:
```powershell
git --version
```
Expected output: `git version 2.x.x`

---

### Step 2: Install Node.js

**WHAT**: JavaScript runtime  
**WHY**: Run UI tests with Playwright

**HOW**:
1. In PowerShell (Admin), run: `winget install OpenJS.NodeJS.LTS`
2. Close and reopen PowerShell

**VERIFY**:
```powershell
node -v    # Should show v20.x.x
npm -v     # Should show 10.x.x
```

---

### Step 3: Install Java 17

**WHAT**: Java Development Kit  
**WHY**: Run API tests with Karate

**HOW**:
1. In PowerShell (Admin), run: `winget install EclipseAdoptium.Temurin.17.JDK`
2. Close and reopen PowerShell

**VERIFY**:
```powershell
java -version    # Should show openjdk version "17.x.x"
```

---

### Step 4: Install Maven

**WHAT**: Java build tool  
**WHY**: Compile and run API tests

**HOW**:
1. In PowerShell (Admin), run: `winget install Apache.Maven`
2. Close and reopen PowerShell

**VERIFY**:
```powershell
mvn -v    # Should show Apache Maven 3.9.x
```

---

### Step 5: Install Docker Desktop

**WHAT**: Container platform  
**WHY**: Run the demo application

**HOW**:
1. Download Docker Desktop from https://www.docker.com/products/docker-desktop/
2. Run the installer
3. Restart your computer when prompted
4. Start Docker Desktop from the Start Menu

**VERIFY**:
```powershell
docker --version    # Should show Docker version 24.x.x
docker ps           # Should list running containers (empty if none)
```

---

### Step 6: Install ripgrep

**WHAT**: Fast text search tool  
**WHY**: Find non-English content in the codebase

**HOW**:
1. In PowerShell (Admin), run: `winget install BurntSushi.ripgrep`
2. Close and reopen PowerShell

**VERIFY**:
```powershell
rg --version    # Should show ripgrep x.x.x
```

---

### Step 7: Install cspell

**WHAT**: Code spell checker  
**WHY**: Enforce English spelling

**HOW**:
1. In PowerShell, run: `npm install -g cspell`

**VERIFY**:
```powershell
npx cspell --version    # Should show x.x.x
```

---

### Step 8: Verify All Prerequisites

**HOW**:
1. In PowerShell, navigate to the project folder:
   ```powershell
   cd C:\path\to\qu-challenge
   ```
2. Run the verification script:
   ```powershell
   .\scripts\verify-prerequisites.ps1
   ```
3. If all checks pass, you're ready!

---

## macOS Installation

### Step 1: Install Homebrew

**WHAT**: Package manager for macOS  
**WHY**: Simplify installation of other tools

**HOW**:
1. Open **Terminal** (Applications → Utilities → Terminal)
2. Run:
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
3. Follow the on-screen instructions

**VERIFY**:
```bash
brew --version
```

---

### Step 2: Install Git

**HOW**:
```bash
brew install git
```

**VERIFY**:
```bash
git --version
```

---

### Step 3: Install Node.js

**HOW**:
```bash
brew install node@20
```

**VERIFY**:
```bash
node -v
npm -v
```

---

### Step 4: Install Java 17

**HOW**:
```bash
brew install openjdk@17
```

**Set JAVA_HOME** (add to `~/.zshrc`):
```bash
echo 'export JAVA_HOME=$(/usr/libexec/java_home -v 17)' >> ~/.zshrc
source ~/.zshrc
```

**VERIFY**:
```bash
java -version
```

---

### Step 5: Install Maven

**HOW**:
```bash
brew install maven
```

**VERIFY**:
```bash
mvn -v
```

---

### Step 6: Install Docker Desktop

**HOW**:
```bash
brew install --cask docker
```
Or download from https://www.docker.com/products/docker-desktop/

**Start Docker Desktop**:
- Open Docker Desktop from Applications

**VERIFY**:
```bash
docker --version
docker ps
```

---

### Step 7: Install ripgrep

**HOW**:
```bash
brew install ripgrep
```

**VERIFY**:
```bash
rg --version
```

---

### Step 8: Install cspell

**HOW**:
```bash
npm install -g cspell
```

**VERIFY**:
```bash
npx cspell --version
```

---

### Step 9: Verify All Prerequisites

**HOW**:
```bash
cd /path/to/qu-challenge
chmod +x scripts/verify-prerequisites.sh
./scripts/verify-prerequisites.sh
```

---

## Linux Installation (Ubuntu/Debian)

### Step 1: Update Package Manager

**HOW**:
```bash
sudo apt update
```

---

### Step 2: Install Git

**HOW**:
```bash
sudo apt install git -y
```

**VERIFY**:
```bash
git --version
```

---

### Step 3: Install Node.js

**HOW**:
```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
```

**VERIFY**:
```bash
node -v
npm -v
```

---

### Step 4: Install Java 17

**HOW**:
```bash
sudo apt install openjdk-17-jdk -y
```

**VERIFY**:
```bash
java -version
```

---

### Step 5: Install Maven

**HOW**:
```bash
sudo apt install maven -y
```

**VERIFY**:
```bash
mvn -v
```

---

### Step 6: Install Docker

**HOW**:
```bash
sudo apt install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker
```

**Add user to docker group** (to avoid using `sudo`):
```bash
sudo usermod -aG docker $USER
newgrp docker
```

**VERIFY**:
```bash
docker --version
docker ps
```

---

### Step 7: Install ripgrep

**HOW**:
```bash
sudo apt install ripgrep -y
```

**VERIFY**:
```bash
rg --version
```

---

### Step 8: Install cspell

**HOW**:
```bash
npm install -g cspell
```

**VERIFY**:
```bash
npx cspell --version
```

---

### Step 9: Verify All Prerequisites

**HOW**:
```bash
cd /path/to/qu-challenge
chmod +x scripts/verify-prerequisites.sh
./scripts/verify-prerequisites.sh
```

---

## Linux Installation (Fedora/RHEL)

### Step 1: Update Package Manager

**HOW**:
```bash
sudo dnf update -y
```

---

### Step 2: Install Git

**HOW**:
```bash
sudo dnf install git -y
```

**VERIFY**:
```bash
git --version
```

---

### Step 3: Install Node.js

**HOW**:
```bash
curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
sudo dnf install nodejs -y
```

**VERIFY**:
```bash
node -v
npm -v
```

---

### Step 4: Install Java 17

**HOW**:
```bash
sudo dnf install java-17-openjdk-devel -y
```

**VERIFY**:
```bash
java -version
```

---

### Step 5: Install Maven

**HOW**:
```bash
sudo dnf install maven -y
```

**VERIFY**:
```bash
mvn -v
```

---

### Step 6: Install Docker

**HOW**:
```bash
sudo dnf install docker -y
sudo systemctl start docker
sudo systemctl enable docker
```

**Add user to docker group**:
```bash
sudo usermod -aG docker $USER
newgrp docker
```

**VERIFY**:
```bash
docker --version
docker ps
```

---

### Step 7: Install ripgrep

**HOW**:
```bash
sudo dnf install ripgrep -y
```

**VERIFY**:
```bash
rg --version
```

---

### Step 8: Install cspell

**HOW**:
```bash
npm install -g cspell
```

**VERIFY**:
```bash
npx cspell --version
```

---

### Step 9: Verify All Prerequisites

**HOW**:
```bash
cd /path/to/qu-challenge
chmod +x scripts/verify-prerequisites.sh
./scripts/verify-prerequisites.sh
```

---

## Next Steps

Once all prerequisites are installed:

1. **Clone the repository** (if not already done):
   ```bash
   git clone <repository-url>
   cd qu-challenge
   ```

2. **Start the demo app**:
   ```bash
   docker run -d --name demo-app -p 3100:3100 automaticbytes/demo-app:latest
   ```

3. **Run UI tests**:
   ```bash
   cd ui-tests
   npm install
   npx playwright install
   npm test
   ```

4. **Run API tests**:
   ```bash
   cd api-tests
   mvn clean test
   ```

5. **Read the full runbook**: [RUNBOOK.md](RUNBOOK.md)

---

## Troubleshooting

### Windows

**Problem**: Command not found after installation  
**Solution**: Close and reopen PowerShell

**Problem**: Docker Desktop won't start  
**Solution**: Enable WSL2 backend in Docker Desktop settings

### macOS

**Problem**: Xcode Command Line Tools missing  
**Solution**: Run `xcode-select --install`

**Problem**: Homebrew permissions error  
**Solution**: Run `sudo chown -R $(whoami) /usr/local/lib/pkgconfig`

### Linux

**Problem**: Docker permission denied  
**Solution**: Add user to docker group (see Step 6 above)

**Problem**: Playwright browser installation fails  
**Solution**: Run `npx playwright install --with-deps`

---

**Congratulations! You're ready to start testing!** 🎉

