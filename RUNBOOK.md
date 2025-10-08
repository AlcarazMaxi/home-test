# QA Automation Cross-Platform Runbook

## Table of Contents
1. [High-Level Plan & Architecture](#1-high-level-plan--architecture)
2. [OS Command Matrix](#2-os-command-matrix)
3. [Prerequisites Per OS](#3-prerequisites-per-os--what-why-how-verify)
4. [Start/Stop Demo App](#4-startstop-the-demo-app-docker--cross-platform)
5. [English-Only Audit](#5-english-only-audit)
6. [English Spelling Guard](#6-english-spelling-guard-cspell)
7. [UI Repo Refactor](#7-ui-repo-refactor-playwright--typescript)
8. [API Repo Refactor](#8-api-repo-refactor-karate--java)
9. [Security, Accessibility, Performance](#9-security-accessibility-and-performance)
10. [CI/CD](#10-cicd-github-actions--cross-os-matrix)
11. [Troubleshooting Per OS](#11-troubleshooting-per-os)
12. [Acceptance Criteria](#12-acceptance-criteria--final-checklist)
13. [Appendix A: OS-Specific Cheat Sheets](#appendix-a--os-specific-cheat-sheets)

---

## 1) High-Level Plan & Architecture

### Quality Assurance Approach
- **Automated audit** using ripgrep to find non-English content
- **Spelling guard** with cspell (en-US only, no non-English dictionaries)
- **Code quality gates** with ESLint/Prettier (UI) and Spotless/Checkstyle (API)
- **CI validation** with cross-OS matrix testing

### Architecture Flow
```
┌─────────────┐    ┌──────────────┐    ┌─────────────┐    ┌─────────────┐
│   Cursor    │───▶│   Git Repos  │───▶│ Docker Demo │───▶│ Test Suites │
│   (Editor)  │    │ (ui/api)     │    │   (App)     │    │ (UI/API)    │
└─────────────┘    └──────────────┘    └─────────────┘    └─────────────┘
       │                   │                   │                   │
       ▼                   ▼                   ▼                   ▼
┌─────────────┐    ┌──────────────┐    ┌─────────────┐    ┌─────────────┐
│  Refactor   │    │   Lint/Spell │    │  Health     │    │   Reports   │
│   Tools     │    │    Gates     │    │   Checks    │    │ (HTML/JSON) │
└─────────────┘    └──────────────┘    └─────────────┘    └─────────────┘
       │                   │                   │                   │
       ▼                   ▼                   ▼                   ▼
┌─────────────┐    ┌──────────────┐    ┌─────────────┐    ┌─────────────┐
│   GitHub    │    │   Quality    │    │  Security   │    │  Performance│
│   Actions   │    │    Gates     │    │   (ZAP)     │    │ (Lighthouse)│
└─────────────┘    └──────────────┘    └─────────────┘    └─────────────┘
```

### Guiding Principles
- **Reproducibility**: Same results on Windows/macOS/Linux
- **Readability**: Clear professional English throughout
- **Naming consistency**: camelCase for variables, PascalCase for classes
- **Zero behavior change**: Only cosmetic/text changes, no logic modifications

---

## 2) OS Command Matrix

| OS | Shell | Package Manager | Java | Node | Docker |
|----|-------|----------------|------|------|--------|
| **Windows** | CMD/PowerShell | winget (default), choco, scoop | Oracle/OpenJDK | NodeSource | Docker Desktop |
| **macOS** | zsh (default), bash | Homebrew | Oracle/OpenJDK | NodeSource | Docker Desktop |
| **Linux (Ubuntu)** | bash | apt | OpenJDK | NodeSource | Docker Engine |
| **Linux (Fedora)** | bash | dnf/yum | OpenJDK | NodeSource | Docker Engine |
| **Linux (Arch)** | bash | pacman | OpenJDK | NodeSource | Docker Engine |

**CPU Architecture Notes:**
- **Windows**: x86_64 (Intel/AMD), ARM64 (Surface Pro X)
- **macOS**: x86_64 (Intel), arm64 (Apple Silicon M1/M2/M3)
- **Linux**: x86_64, ARM64 (Raspberry Pi, AWS Graviton)

---

## 3) Prerequisites Per OS — WHAT, WHY, HOW, VERIFY

### 3.1) Git

**WHAT**: Version control system  
**WHY**: Clone repos, track changes, collaborate

**HOW TO INSTALL**:

| OS | Command |
|----|---------|
| **Windows (winget)** | `winget install Git.Git` |
| **Windows (choco)** | `choco install git` |
| **macOS** | `brew install git` |
| **Ubuntu/Debian** | `sudo apt update && sudo apt install git -y` |
| **Fedora/RHEL** | `sudo dnf install git -y` |
| **Arch** | `sudo pacman -S git --noconfirm` |

**VERIFY**: `git --version`  
Expected output: `git version 2.x.x`

---

### 3.2) Node.js LTS (v20.x)

**WHAT**: JavaScript runtime for UI tests  
**WHY**: Run Playwright, TypeScript compilation, npm packages

**HOW TO INSTALL**:

| OS | Command |
|----|---------|
| **Windows (winget)** | `winget install OpenJS.NodeJS.LTS` |
| **Windows (choco)** | `choco install nodejs-lts` |
| **macOS** | `brew install node@20` |
| **Ubuntu/Debian** | `curl -fsSL https://deb.nodesource.com/setup_20.x \| sudo -E bash - && sudo apt-get install -y nodejs` |
| **Fedora/RHEL** | `curl -fsSL https://rpm.nodesource.com/setup_20.x \| sudo bash - && sudo dnf install nodejs -y` |
| **Arch** | `sudo pacman -S nodejs npm --noconfirm` |

**VERIFY**: 
```bash
node -v    # Should show v20.x.x
npm -v     # Should show 10.x.x
```

---

### 3.3) Java 17

**WHAT**: Java Development Kit for API tests  
**WHY**: Run Karate tests, Maven builds

**HOW TO INSTALL**:

| OS | Command |
|----|---------|
| **Windows (winget)** | `winget install EclipseAdoptium.Temurin.17.JDK` |
| **Windows (choco)** | `choco install temurin17` |
| **macOS** | `brew install openjdk@17` |
| **Ubuntu/Debian** | `sudo apt update && sudo apt install openjdk-17-jdk -y` |
| **Fedora/RHEL** | `sudo dnf install java-17-openjdk-devel -y` |
| **Arch** | `sudo pacman -S jdk17-openjdk --noconfirm` |

**VERIFY**: 
```bash
java -version    # Should show openjdk version "17.x.x"
javac -version   # Should show javac 17.x.x
```

**PATH Configuration (if multiple JDKs exist)**:
- **Windows**: Set `JAVA_HOME` to `C:\Program Files\Eclipse Adoptium\jdk-17.x.x-hotspot`
- **macOS**: Add to `~/.zshrc`: `export JAVA_HOME=$(/usr/libexec/java_home -v 17)`
- **Linux**: Add to `~/.bashrc`: `export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64`

---

### 3.4) Maven 3.9.x

**WHAT**: Java build tool  
**WHY**: Compile Java, run tests, manage dependencies

**HOW TO INSTALL**:

| OS | Command |
|----|---------|
| **Windows (winget)** | `winget install Apache.Maven` |
| **Windows (choco)** | `choco install maven` |
| **macOS** | `brew install maven` |
| **Ubuntu/Debian** | `sudo apt update && sudo apt install maven -y` |
| **Fedora/RHEL** | `sudo dnf install maven -y` |
| **Arch** | `sudo pacman -S maven --noconfirm` |

**VERIFY**: 
```bash
mvn -v    # Should show Apache Maven 3.9.x
```

---

### 3.5) Docker Desktop/Engine

**WHAT**: Container runtime for demo app  
**WHY**: Run demo app, isolate test environment

**HOW TO INSTALL**:

| OS | Command/Link |
|----|--------------|
| **Windows** | Download from https://www.docker.com/products/docker-desktop/ or `winget install Docker.DockerDesktop` |
| **macOS** | `brew install --cask docker` or download from https://www.docker.com/products/docker-desktop/ |
| **Ubuntu/Debian** | `sudo apt update && sudo apt install docker.io -y && sudo systemctl start docker && sudo systemctl enable docker` |
| **Fedora/RHEL** | `sudo dnf install docker -y && sudo systemctl start docker && sudo systemctl enable docker` |
| **Arch** | `sudo pacman -S docker --noconfirm && sudo systemctl start docker && sudo systemctl enable docker` |

**Post-Install (Linux)**: Add user to docker group to avoid `sudo`:
```bash
sudo usermod -aG docker $USER
newgrp docker
```

**VERIFY**: 
```bash
docker --version    # Should show Docker version 24.x.x or higher
docker ps           # Should list running containers (empty if none)
```

---

### 3.6) ripgrep (rg)

**WHAT**: Fast text search tool  
**WHY**: Find non-English content, audit codebase

**HOW TO INSTALL**:

| OS | Command |
|----|---------|
| **Windows (winget)** | `winget install BurntSushi.ripgrep` |
| **Windows (choco)** | `choco install ripgrep` |
| **macOS** | `brew install ripgrep` |
| **Ubuntu/Debian** | `sudo apt update && sudo apt install ripgrep -y` |
| **Fedora/RHEL** | `sudo dnf install ripgrep -y` |
| **Arch** | `sudo pacman -S ripgrep --noconfirm` |

**VERIFY**: 
```bash
rg --version    # Should show ripgrep x.x.x
```

---

### 3.7) cspell (Code Spell Checker)

**WHAT**: Code spell checker  
**WHY**: Enforce English, catch typos

**HOW TO INSTALL**:
```bash
npm install -g cspell
```

**VERIFY**: 
```bash
npx cspell --version    # Should show x.x.x
```

---

### 3.8) jscodeshift (TypeScript Codemod Tool)

**WHAT**: JavaScript/TypeScript codemod tool  
**WHY**: Programmatic refactoring, rename identifiers

**HOW TO INSTALL**:
```bash
npm install -g jscodeshift
```

**VERIFY**: 
```bash
npx jscodeshift --version    # Should show x.x.x
```

---

### 3.9) Allure (Optional)

**WHAT**: Test reporting framework  
**WHY**: Beautiful HTML reports, test analytics

**HOW TO INSTALL**:
```bash
npm install -g allure-commandline
```

**VERIFY**: 
```bash
allure --version    # Should show x.x.x
```

---

## 4) Start/Stop the Demo App (Docker) — Cross-Platform

### 4.1) Pull the Demo App Image

```bash
docker pull automaticbytes/demo-app:latest
```

### 4.2) Start the Demo App

**CMD (Windows)**:
```cmd
docker run -d --name demo-app -p 3100:3100 automaticbytes/demo-app:latest
```

**PowerShell (Windows)**:
```powershell
docker run -d --name demo-app -p 3100:3100 automaticbytes/demo-app:latest
```

**macOS/Linux**:
```bash
docker run -d --name demo-app -p 3100:3100 automaticbytes/demo-app:latest
```

### 4.3) Health Check

**Windows (PowerShell)**:
```powershell
Invoke-WebRequest -Uri http://localhost:3100/health
```

**Windows (CMD with curl)**:
```cmd
curl http://localhost:3100/health
```

**macOS/Linux**:
```bash
curl http://localhost:3100/health
```

Expected response: `{"status":"ok"}`

### 4.4) Check API Endpoint

```bash
curl http://localhost:3100/api/health
```

### 4.5) Stop and Clean

```bash
# Stop the container
docker stop demo-app

# Remove the container
docker rm -f demo-app
```

### 4.6) Troubleshooting

| Issue | Windows | macOS | Linux |
|-------|---------|-------|-------|
| **Port 3100 already in use** | `netstat -ano \| findstr :3100` then `taskkill /PID <PID> /F` | `lsof -ti:3100 \| xargs kill -9` | `sudo lsof -ti:3100 \| xargs sudo kill -9` |
| **Docker not running** | Start Docker Desktop from Start Menu | Open Docker Desktop app | `sudo systemctl start docker` |
| **Permission denied** | Run PowerShell as Administrator | Check Docker Desktop is running | Add user to docker group: `sudo usermod -aG docker $USER` |
| **Firewall blocking** | Windows Defender Firewall → Allow app → Docker | System Preferences → Security → Allow Docker | `sudo ufw allow 3100/tcp` |

---

## 5) Language Content Audit

### 5.1) Automated Search for Non-English Content

Use ripgrep to find accented characters and common Spanish words:

**Windows (CMD)**:
```cmd
rg -i "á|é|í|ó|ú|ñ|ü|¿|¡|hola|mundo|gracias|adiós|hasta" --type ts --type js --type java --type md > audit-non-english.txt
```

**Windows (PowerShell)**:
```powershell
rg -i "á|é|í|ó|ú|ñ|ü|¿|¡|hola|mundo|gracias|adiós|hasta" --type ts --type js --type java --type md | Out-File -Encoding UTF8 audit-non-english.txt
```

**macOS/Linux**:
```bash
rg -i "á|é|í|ó|ú|ñ|ü|¿|¡|hola|mundo|gracias|adiós|hasta" --type ts --type js --type java --type md > audit-non-english.txt
```

### 5.2) Interpret Results

Review `audit-non-english.txt`:
- **Code identifiers**: Rename to English equivalents (e.g., `nombreUsuario` → `userName`)
- **Comments**: Translate to English
- **Test names**: Translate to English
- **Log messages**: Translate to English
- **Documentation**: Translate to English

### 5.3) Prioritization

1. **High priority**: Code identifiers (variables, functions, classes)
2. **Medium priority**: Test names, comments
3. **Low priority**: Documentation, commit messages

---

## 6) Spelling Guard (cspell)

### 6.1) Configuration Files

Both `ui-tests/cspell.config.cjs` and `api-tests/cspell.config.cjs` are already created with:
- `language: "en-US"` (English only)
- No non-English dictionaries
- Curated allowlist for technical terms

### 6.2) Run cspell

**UI Tests (npm)**:

Add to `ui-tests/package.json`:
```json
{
  "scripts": {
    "spell": "cspell --no-progress \"**/*.{ts,js,md,json}\"",
    "spell:fix": "cspell --no-progress --show-suggestions \"**/*.{ts,js,md,json}\""
  }
}
```

Run:
```bash
cd ui-tests
npm run spell
```

**API Tests (Maven exec plugin)**:

Add to `api-tests/pom.xml`:
```xml
<plugin>
  <groupId>org.codehaus.mojo</groupId>
  <artifactId>exec-maven-plugin</artifactId>
  <version>3.1.0</version>
  <executions>
    <execution>
      <id>spell-check</id>
      <phase>validate</phase>
      <goals>
        <goal>exec</goal>
      </goals>
      <configuration>
        <executable>npx</executable>
        <arguments>
          <argument>cspell</argument>
          <argument>--no-progress</argument>
          <argument>src/**/*.{java,feature,md}</argument>
        </arguments>
      </configuration>
    </execution>
  </executions>
</plugin>
```

Run:
```bash
cd api-tests
mvn validate
```

### 6.3) Fail CI on Spelling Violations

In GitHub Actions (`.github/workflows/*.yml`):
```yaml
- name: Spell Check
  run: npm run spell
  # Exit code 1 if errors found, fails the build
```

### 6.4) Add Words to Allowlist

Edit `cspell.config.cjs`:
```javascript
words: [
  "playwright",
  "testid",
  "yourNewTerm"  // Add here
]
```

---

## 7) UI Repo Refactor (Playwright + TypeScript)

### 7.1) Install Dependencies

**Windows/macOS/Linux**:
```bash
cd ui-tests
npm install
```

### 7.2) Install Playwright Browsers

**Windows/macOS**:
```bash
npx playwright install
```

**Linux** (with system dependencies):
```bash
npx playwright install --with-deps
```

### 7.3) ESLint + Prettier Setup

**ESLint config** (`ui-tests/.eslintrc.js`):
```javascript
module.exports = {
  parser: '@typescript-eslint/parser',
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended',
    'plugin:playwright/recommended',
    'prettier'
  ],
  plugins: ['@typescript-eslint', 'playwright'],
  env: {
    node: true,
    es2022: true
  },
  rules: {
    '@typescript-eslint/no-unused-vars': 'error',
    '@typescript-eslint/explicit-function-return-type': 'warn'
  }
};
```

**Prettier config** (`ui-tests/.prettierrc`):
```json
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 100,
  "tabWidth": 2
}
```

**Add npm scripts** to `package.json`:
```json
{
  "scripts": {
    "lint": "eslint . --ext .ts,.js",
    "lint:fix": "eslint . --ext .ts,.js --fix",
    "format": "prettier --write \"**/*.{ts,js,json,md}\"",
    "format:check": "prettier --check \"**/*.{ts,js,json,md}\""
  }
}
```

### 7.4) Programmatic Renames with jscodeshift

**Example codemod** (`codemods/spanish-to-english.js`):
```javascript
// Rename Spanish identifiers to English
module.exports = function transformer(file, api) {
  const j = api.jscodeshift;
  const root = j(file.source);
  
  // Rename variables
  const renamings = {
    'nombreUsuario': 'userName',
    'contraseña': 'password',
    'botonEnviar': 'submitButton'
  };
  
  Object.keys(renamings).forEach(oldName => {
    const newName = renamings[oldName];
    
    // Rename variable declarations
    root.find(j.Identifier, { name: oldName })
      .forEach(path => {
        path.node.name = newName;
      });
  });
  
  return root.toSource();
};
```

**Run codemod**:
```bash
npx jscodeshift -t codemods/spanish-to-english.js ui-tests/**/*.ts
```

### 7.5) Update Test Names and Comments

Manually review and update:
- `test('Spanish test name', ...)` → `test('English test name', ...)`
- `// Spanish comment` → `// English comment`
- Log messages: `console.log('Spanish message')` → `console.log('English message')`

### 7.6) Run Tests

**All tests (headless)**:
```bash
cd ui-tests
npm test
```

**All tests (headed)**:
```bash
cd ui-tests
npx playwright test --headed
```

**Single test file**:
```bash
cd ui-tests
npx playwright test tests/login.spec.ts
```

**By project (browser)**:
```bash
cd ui-tests
npx playwright test --project=chromium
npx playwright test --project=firefox
npx playwright test --project=webkit
```

**By tag**:
```bash
cd ui-tests
npx playwright test --grep @smoke
```

**Parallel execution** (default):
```bash
cd ui-tests
npx playwright test --workers=4
```

### 7.7) Open Reports

**HTML report**:
```bash
cd ui-tests
npx playwright show-report
```

**Trace viewer** (for failed tests):
```bash
cd ui-tests
npx playwright show-trace test-results/tests-login-Login-chromium/trace.zip
```

---

## 8) API Repo Refactor (Karate + Java)

### 8.1) Install Dependencies

**Windows/macOS/Linux**:
```bash
cd api-tests
mvn clean install -DskipTests
```

### 8.2) Spotless/Checkstyle/SpotBugs Setup

**Add to `pom.xml`** (inside `<build><plugins>`):

```xml
<!-- Spotless: Code formatter -->
<plugin>
  <groupId>com.diffplug.spotless</groupId>
  <artifactId>spotless-maven-plugin</artifactId>
  <version>2.40.0</version>
  <configuration>
    <java>
      <googleJavaFormat>
        <version>1.17.0</version>
        <style>GOOGLE</style>
      </googleJavaFormat>
    </java>
  </configuration>
</plugin>

<!-- Checkstyle: Code style checker -->
<plugin>
  <groupId>org.apache.maven.plugins</groupId>
  <artifactId>maven-checkstyle-plugin</artifactId>
  <version>3.3.0</version>
  <configuration>
    <configLocation>google_checks.xml</configLocation>
    <consoleOutput>true</consoleOutput>
    <failsOnError>true</failsOnError>
  </configuration>
  <executions>
    <execution>
      <phase>validate</phase>
      <goals>
        <goal>check</goal>
      </goals>
    </execution>
  </executions>
</plugin>

<!-- SpotBugs: Static analysis -->
<plugin>
  <groupId>com.github.spotbugs</groupId>
  <artifactId>spotbugs-maven-plugin</artifactId>
  <version>4.7.3.6</version>
  <executions>
    <execution>
      <phase>verify</phase>
      <goals>
        <goal>check</goal>
      </goals>
    </execution>
  </executions>
</plugin>
```

### 8.3) Run Formatters and Linters

**Format code**:
```bash
cd api-tests
mvn spotless:apply
```

**Check style**:
```bash
cd api-tests
mvn checkstyle:check
```

**Run SpotBugs**:
```bash
cd api-tests
mvn spotbugs:check
```

### 8.4) OpenRewrite Recipe for Renames

**Create `rewrite.yml`**:
```yaml
---
type: specs.openrewrite.org/v1beta/recipe
name: com.example.SpanishToEnglish
displayName: Spanish to English identifier renames
description: Renames Spanish identifiers to English equivalents
recipeList:
  - org.openrewrite.java.ChangeMethodName:
      methodPattern: "com.example.* getNombreUsuario()"
      newMethodName: "getUserName"
  - org.openrewrite.java.ChangeMethodName:
      methodPattern: "com.example.* setNombreUsuario(String)"
      newMethodName: "setUserName"
```

**Run OpenRewrite** (requires plugin in `pom.xml`):
```bash
mvn rewrite:run
```

### 8.5) Convert Karate Features to English

Manually review and update `.feature` files:
```gherkin
# Before
Escenario: Obtener lista de inventario
  Dado que el API está disponible
  Cuando obtengo /api/inventory
  Entonces el código de respuesta es 200

# After
Scenario: Get inventory list
  Given the API is available
  When I GET /api/inventory
  Then the response code is 200
```

### 8.6) Run Tests

**All tests**:

**Windows (CMD)**:
```cmd
cd api-tests
mvn clean test
```

**Windows (PowerShell)**:
```powershell
cd api-tests
mvn clean test
```

**macOS/Linux**:
```bash
cd api-tests
mvn clean test
```

**By tag**:

**Windows (CMD)**:
```cmd
cd api-tests
mvn test -Dkarate.options="--tags @smoke"
```

**Windows (PowerShell)**:
```powershell
cd api-tests
mvn test "-Dkarate.options=--tags @smoke"
```

**macOS/Linux**:
```bash
cd api-tests
mvn test -Dkarate.options="--tags @smoke"
```

**Single scenario**:
```bash
cd api-tests
mvn test -Dkarate.options="src/test/resources/features/inventory.feature:10"
```

### 8.7) Open Reports

**Karate HTML report**: Open `api-tests/target/karate-reports/karate-summary.html` in a browser.

**Windows**:
```cmd
start target\karate-reports\karate-summary.html
```

**macOS**:
```bash
open target/karate-reports/karate-summary.html
```

**Linux**:
```bash
xdg-open target/karate-reports/karate-summary.html
```

---

## 9) Security, Accessibility, and Performance

### 9.1) OWASP ZAP Baseline Scan

**Run ZAP in Docker**:

**Windows (CMD)**:
```cmd
docker run -t owasp/zap2docker-stable zap-baseline.py -t http://host.docker.internal:3100 -r zap-report.html
```

**Windows (PowerShell)**:
```powershell
docker run -t owasp/zap2docker-stable zap-baseline.py -t http://host.docker.internal:3100 -r zap-report.html
```

**macOS**:
```bash
docker run -t owasp/zap2docker-stable zap-baseline.py -t http://host.docker.internal:3100 -r zap-report.html
```

**Linux**:
```bash
docker run -t --network=host owasp/zap2docker-stable zap-baseline.py -t http://localhost:3100 -r zap-report.html
```

**Save report**:
```bash
docker cp <container_id>:/zap/wrk/zap-report.html ./zap-report.html
```

**Interpret findings**:
- **High/Medium**: Review and fix (e.g., missing security headers)
- **Low/Informational**: Document as known issues or suppress

### 9.2) Accessibility Checks with axe-core

**Add to UI tests** (`ui-tests/utils/accessibility.ts`):
```typescript
import { Page } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

// Run axe accessibility scan on the current page
export async function runAccessibilityScan(page: Page): Promise<void> {
  const accessibilityScanResults = await new AxeBuilder({ page }).analyze();
  
  // Assert no violations found
  expect(accessibilityScanResults.violations).toEqual([]);
}
```

**Use in tests** (`ui-tests/tests/accessibility.spec.ts`):
```typescript
import { test } from '@playwright/test';
import { runAccessibilityScan } from '../utils/accessibility';

test('Login page should have no accessibility violations', async ({ page }) => {
  await page.goto('/login');
  await runAccessibilityScan(page);
});
```

### 9.3) Lighthouse CI

**Install Lighthouse CI**:
```bash
npm install -g @lhci/cli
```

**Create config** (`ui-tests/lighthouserc.js`):
```javascript
module.exports = {
  ci: {
    collect: {
      url: ['http://localhost:3100/login', 'http://localhost:3100/checkout'],
      numberOfRuns: 3,
    },
    assert: {
      assertions: {
        'categories:performance': ['error', {minScore: 0.8}],
        'categories:accessibility': ['error', {minScore: 0.9}],
      },
    },
    upload: {
      target: 'temporary-public-storage',
    },
  },
};
```

**Run Lighthouse CI**:

**Windows/macOS/Linux**:
```bash
cd ui-tests
lhci autorun
```

**Interpret results**:
- **Performance < 80**: Optimize images, lazy loading, code splitting
- **Accessibility < 90**: Fix color contrast, ARIA labels, keyboard navigation

---

## 10) CI/CD (GitHub Actions) — Cross-OS Matrix

### 10.1) UI Tests Workflow

**Create `.github/workflows/ui-tests.yml`** (in `ui-tests/` repo):

```yaml
name: UI Tests

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  ui-tests:
    name: UI Tests - ${{ matrix.os }} - ${{ matrix.browser }}
    runs-on: ${{ matrix.os }}
    
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
        browser: [chromium, firefox, webkit]
    
    services:
      demo-app:
        image: automaticbytes/demo-app:latest
        ports:
          - 3100:3100
        options: >-
          --health-cmd "curl -f http://localhost:3100/health || exit 1"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Install Playwright browsers
        run: npx playwright install --with-deps ${{ matrix.browser }}
      
      - name: Run spell check
        run: npm run spell
      
      - name: Run linter
        run: npm run lint
      
      - name: Run Playwright tests
        run: npx playwright test --project=${{ matrix.browser }}
        env:
          BASE_URL: http://localhost:3100
      
      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: playwright-report-${{ matrix.os }}-${{ matrix.browser }}
          path: playwright-report/
          retention-days: 30
      
      - name: Upload traces
        if: failure()
        uses: actions/upload-artifact@v4
        with:
          name: playwright-traces-${{ matrix.os }}-${{ matrix.browser }}
          path: test-results/
          retention-days: 30
```

### 10.2) API Tests Workflow

**Create `.github/workflows/api-tests.yml`** (in `api-tests/` repo):

```yaml
name: API Tests

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  api-tests:
    name: API Tests - ${{ matrix.os }}
    runs-on: ${{ matrix.os }}
    
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
    
    services:
      demo-app:
        image: automaticbytes/demo-app:latest
        ports:
          - 3100:3100
        options: >-
          --health-cmd "curl -f http://localhost:3100/health || exit 1"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Setup Java 17
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'
          cache: 'maven'
      
      - name: Setup Node.js (for cspell)
        uses: actions/setup-node@v4
        with:
          node-version: '20'
      
      - name: Install cspell
        run: npm install -g cspell
      
      - name: Run spell check
        run: npx cspell "src/**/*.{java,feature,md}"
      
      - name: Run Checkstyle
        run: mvn checkstyle:check
      
      - name: Run Karate tests
        run: mvn clean test
        env:
          BASE_URL: http://localhost:3100/api
      
      - name: Upload Karate reports
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: karate-reports-${{ matrix.os }}
          path: target/karate-reports/
          retention-days: 30
```

### 10.3) Trade-offs

| Aspect | Full Matrix | Limited Matrix |
|--------|-------------|----------------|
| **Coverage** | All OS/browsers | Ubuntu + Chromium only |
| **Cost** | High (9+ jobs) | Low (1 job) |
| **Time** | 30-45 min | 5-10 min |
| **When to use** | Pre-release | PR checks |

**Recommendation**: Run full matrix on `main` push, limited matrix on PR.

---

## 11) Troubleshooting Per OS

### 11.1) Windows

| Issue | Solution |
|-------|----------|
| **PATH not updated** | Close and reopen terminal after install |
| **Multiple JDKs** | Set `JAVA_HOME` in System Environment Variables |
| **PowerShell quoting** | Use double quotes around `-Dkarate.options="--tags @smoke"` |
| **Playwright browsers fail** | Run `npx playwright install` again or check corporate proxy |
| **Docker Desktop not starting** | Enable WSL2 backend in Docker Desktop settings |

### 11.2) macOS

| Issue | Solution |
|-------|----------|
| **Xcode CLT missing** | Run `xcode-select --install` |
| **Homebrew permissions** | Run `sudo chown -R $(whoami) /usr/local/lib/pkgconfig` |
| **Apple Silicon containers** | Use `--platform linux/amd64` for x86_64 images |
| **Java not found** | Add `export JAVA_HOME=$(/usr/libexec/java_home -v 17)` to `~/.zshrc` |

### 11.3) Linux

| Issue | Solution |
|-------|----------|
| **Playwright system libs** | Run `npx playwright install --with-deps` |
| **Docker permission denied** | Add user to docker group: `sudo usermod -aG docker $USER` |
| **Port already in use** | Kill process: `sudo lsof -ti:3100 \| xargs sudo kill -9` |
| **SELinux/firewalld** | Run `sudo setenforce 0` (temporary) or `sudo firewall-cmd --add-port=3100/tcp --permanent` |

---

## 12) Acceptance Criteria & Final Checklist

- [ ] All prerequisites installed on target OS (Windows/macOS/Linux)
- [ ] Demo app starts and health checks pass
- [ ] UI tests pass locally (`npm test`)
- [ ] API tests pass locally (`mvn test`)
- [ ] No Spanish text detected by ripgrep
- [ ] cspell passes with 0 errors
- [ ] ESLint/Prettier pass (UI)
- [ ] Checkstyle/SpotBugs pass (API)
- [ ] GitHub Actions workflows green on at least one OS
- [ ] HTML reports generated and viewable
- [ ] READMEs updated with professional English and OS-specific instructions
- [ ] Commit messages in professional English

---

## Appendix A — OS-Specific Cheat Sheets

### A.1) Windows (CMD)

```cmd
REM Install prerequisites (winget)
winget install Git.Git
winget install OpenJS.NodeJS.LTS
winget install EclipseAdoptium.Temurin.17.JDK
winget install Apache.Maven
winget install Docker.DockerDesktop
winget install BurntSushi.ripgrep

REM Start demo app
docker run -d --name demo-app -p 3100:3100 automaticbytes/demo-app:latest

REM UI tests
cd ui-tests
npm install
npx playwright install
npm test
npx playwright show-report

REM API tests
cd api-tests
mvn clean test
start target\karate-reports\karate-summary.html

REM Run cspell
cd ui-tests
npm run spell
cd ..\api-tests
npx cspell "src/**/*.{java,feature,md}"

REM Stop demo app
docker stop demo-app
docker rm -f demo-app
```

### A.2) Windows (PowerShell)

```powershell
# Install prerequisites (winget)
winget install Git.Git
winget install OpenJS.NodeJS.LTS
winget install EclipseAdoptium.Temurin.17.JDK
winget install Apache.Maven
winget install Docker.DockerDesktop
winget install BurntSushi.ripgrep

# Start demo app
docker run -d --name demo-app -p 3100:3100 automaticbytes/demo-app:latest

# UI tests
cd ui-tests
npm install
npx playwright install
npm test
npx playwright show-report

# API tests (note the quoting for Maven options)
cd api-tests
mvn clean test
Start-Process target\karate-reports\karate-summary.html

# Run cspell
cd ui-tests
npm run spell
cd ..\api-tests
npx cspell "src/**/*.{java,feature,md}"

# Stop demo app
docker stop demo-app
docker rm -f demo-app
```

### A.3) macOS (zsh/bash)

```bash
# Install prerequisites (Homebrew)
brew install git
brew install node@20
brew install openjdk@17
brew install maven
brew install --cask docker
brew install ripgrep

# Start demo app
docker run -d --name demo-app -p 3100:3100 automaticbytes/demo-app:latest

# UI tests
cd ui-tests
npm install
npx playwright install
npm test
npx playwright show-report

# API tests
cd api-tests
mvn clean test
open target/karate-reports/karate-summary.html

# Run cspell
cd ui-tests
npm run spell
cd ../api-tests
npx cspell "src/**/*.{java,feature,md}"

# Stop demo app
docker stop demo-app
docker rm -f demo-app
```

### A.4) Linux (Ubuntu/Debian)

```bash
# Install prerequisites (apt)
sudo apt update
sudo apt install -y git nodejs npm openjdk-17-jdk maven docker.io ripgrep

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Start demo app
docker run -d --name demo-app -p 3100:3100 automaticbytes/demo-app:latest

# UI tests
cd ui-tests
npm install
npx playwright install --with-deps
npm test
npx playwright show-report

# API tests
cd api-tests
mvn clean test
xdg-open target/karate-reports/karate-summary.html

# Run cspell
cd ui-tests
npm run spell
cd ../api-tests
npx cspell "src/**/*.{java,feature,md}"

# Stop demo app
docker stop demo-app
docker rm -f demo-app
```

### A.5) Linux (Fedora/RHEL)

```bash
# Install prerequisites (dnf)
sudo dnf install -y git nodejs npm java-17-openjdk-devel maven docker ripgrep

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Start demo app
docker run -d --name demo-app -p 3100:3100 automaticbytes/demo-app:latest

# UI tests
cd ui-tests
npm install
npx playwright install --with-deps
npm test
npx playwright show-report

# API tests
cd api-tests
mvn clean test
xdg-open target/karate-reports/karate-summary.html

# Run cspell
cd ui-tests
npm run spell
cd ../api-tests
npx cspell "src/**/*.{java,feature,md}"

# Stop demo app
docker stop demo-app
docker rm -f demo-app
```

---

## End of Runbook

**Next Steps**:
1. Follow the prerequisite installation steps for your OS
2. Start the demo app
3. Run the English-only audit
4. Set up cspell and run spell checks
5. Refactor code to professional English
6. Run all tests locally
7. Commit changes and push to GitHub
8. Verify CI/CD workflows pass

**Support**: For issues, refer to Section 11 (Troubleshooting Per OS).

