# PowerShell script to verify all prerequisites are installed
# Usage: .\scripts\verify-prerequisites.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "QA Automation Prerequisites Checker" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$allGood = $true

# Function to check if a command exists
function Test-Command {
    param (
        [string]$Command
    )
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    } catch {
        return $false
    }
}

# Check Git
Write-Host "Checking Git..." -NoNewline
if (Test-Command "git") {
    $gitVersion = git --version
    Write-Host " ✓ PASS" -ForegroundColor Green
    Write-Host "  Version: $gitVersion" -ForegroundColor Gray
} else {
    Write-Host " ✗ FAIL" -ForegroundColor Red
    Write-Host "  Install: winget install Git.Git" -ForegroundColor Yellow
    $allGood = $false
}
Write-Host ""

# Check Node.js
Write-Host "Checking Node.js..." -NoNewline
if (Test-Command "node") {
    $nodeVersion = node -v
    Write-Host " ✓ PASS" -ForegroundColor Green
    Write-Host "  Version: $nodeVersion" -ForegroundColor Gray
    if (Test-Command "npm") {
        $npmVersion = npm -v
        Write-Host "  npm Version: $npmVersion" -ForegroundColor Gray
    }
} else {
    Write-Host " ✗ FAIL" -ForegroundColor Red
    Write-Host "  Install: winget install OpenJS.NodeJS.LTS" -ForegroundColor Yellow
    $allGood = $false
}
Write-Host ""

# Check Java
Write-Host "Checking Java..." -NoNewline
if (Test-Command "java") {
    $javaVersion = java -version 2>&1 | Select-Object -First 1
    Write-Host " ✓ PASS" -ForegroundColor Green
    Write-Host "  Version: $javaVersion" -ForegroundColor Gray
} else {
    Write-Host " ✗ FAIL" -ForegroundColor Red
    Write-Host "  Install: winget install EclipseAdoptium.Temurin.17.JDK" -ForegroundColor Yellow
    $allGood = $false
}
Write-Host ""

# Check Maven
Write-Host "Checking Maven..." -NoNewline
if (Test-Command "mvn") {
    $mvnVersion = mvn -v | Select-Object -First 1
    Write-Host " ✓ PASS" -ForegroundColor Green
    Write-Host "  Version: $mvnVersion" -ForegroundColor Gray
} else {
    Write-Host " ✗ FAIL" -ForegroundColor Red
    Write-Host "  Install: winget install Apache.Maven" -ForegroundColor Yellow
    $allGood = $false
}
Write-Host ""

# Check Docker
Write-Host "Checking Docker..." -NoNewline
if (Test-Command "docker") {
    $dockerVersion = docker --version
    Write-Host " ✓ PASS" -ForegroundColor Green
    Write-Host "  Version: $dockerVersion" -ForegroundColor Gray
    
    # Check if Docker daemon is running
    try {
        docker ps | Out-Null
        Write-Host "  Docker daemon: Running ✓" -ForegroundColor Gray
    } catch {
        Write-Host "  Docker daemon: Not running ✗" -ForegroundColor Yellow
        Write-Host "  Action: Start Docker Desktop" -ForegroundColor Yellow
    }
} else {
    Write-Host " ✗ FAIL" -ForegroundColor Red
    Write-Host "  Install: winget install Docker.DockerDesktop" -ForegroundColor Yellow
    $allGood = $false
}
Write-Host ""

# Check ripgrep
Write-Host "Checking ripgrep..." -NoNewline
if (Test-Command "rg") {
    $rgVersion = rg --version | Select-Object -First 1
    Write-Host " ✓ PASS" -ForegroundColor Green
    Write-Host "  Version: $rgVersion" -ForegroundColor Gray
} else {
    Write-Host " ✗ FAIL" -ForegroundColor Red
    Write-Host "  Install: winget install BurntSushi.ripgrep" -ForegroundColor Yellow
    $allGood = $false
}
Write-Host ""

# Check cspell
Write-Host "Checking cspell..." -NoNewline
if (Test-Command "npx") {
    try {
        $cspellVersion = npx cspell --version 2>&1
        Write-Host " ✓ PASS" -ForegroundColor Green
        Write-Host "  Version: $cspellVersion" -ForegroundColor Gray
    } catch {
        Write-Host " ✗ FAIL" -ForegroundColor Red
        Write-Host "  Install: npm install -g cspell" -ForegroundColor Yellow
        $allGood = $false
    }
} else {
    Write-Host " ✗ FAIL" -ForegroundColor Red
    Write-Host "  Install Node.js first" -ForegroundColor Yellow
    $allGood = $false
}
Write-Host ""

# Check Playwright (optional, but helpful)
Write-Host "Checking Playwright (optional)..." -NoNewline
if (Test-Command "npx") {
    try {
        $playwrightVersion = npx playwright --version 2>&1
        Write-Host " ✓ PASS" -ForegroundColor Green
        Write-Host "  Version: $playwrightVersion" -ForegroundColor Gray
    } catch {
        Write-Host " ⚠ NOT FOUND" -ForegroundColor Yellow
        Write-Host "  Install: cd ui-tests && npm install && npx playwright install" -ForegroundColor Gray
    }
} else {
    Write-Host " ⚠ SKIP" -ForegroundColor Yellow
}
Write-Host ""

# Summary
Write-Host "========================================" -ForegroundColor Cyan
if ($allGood) {
    Write-Host "✓ All prerequisites are installed!" -ForegroundColor Green
    Write-Host "You're ready to run the tests." -ForegroundColor Green
} else {
    Write-Host "✗ Some prerequisites are missing." -ForegroundColor Red
    Write-Host "Please install the missing tools using the commands above." -ForegroundColor Yellow
}
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Exit with appropriate code
if ($allGood) {
    exit 0
} else {
    exit 1
}

