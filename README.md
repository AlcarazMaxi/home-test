# QA Automation Challenge

[![UI Tests](https://github.com/AlcarazMaxi/ui-tests/workflows/UI%20Tests/badge.svg)](https://github.com/AlcarazMaxi/ui-tests/actions)
[![API Tests](https://github.com/AlcarazMaxi/api-tests/workflows/API%20Tests/badge.svg)](https://github.com/AlcarazMaxi/api-tests/actions)

## Overview

This project includes:

1. **UI Automation Tests** (`ui-tests/`) — Playwright + TypeScript + POM
2. **API Automation Tests** (`api-tests/`) — Karate + Java 17 + Maven

## Key Features

✅ **Cross-platform**: Windows, macOS, Linux  
✅ **Cross-browser**: Chromium, Firefox, WebKit  
✅ **Professional English**: Enforced with cspell and ripgrep  
✅ **Quality gates**: ESLint, Prettier, Checkstyle, SpotBugs, Spotless  
✅ **CI/CD**: GitHub Actions with OS matrix testing  
✅ **Docker**: Containerized demo app and test runners  
✅ **Accessibility**: axe-core integration  
✅ **Performance**: Lighthouse CI  
✅ **Security**: OWASP ZAP Baseline  
✅ **Reports**: HTML, Allure, Karate reports  

## Quick Links

- 📖 **[RUNBOOK.md](RUNBOOK.md)**: Complete cross-platform setup and execution guide
- 📝 **[DELIVERABLES.md](DELIVERABLES.md)**: Deliverables checklist and project summary
- 🎭 **[ui-tests/README.md](ui-tests/README.md)**: UI tests documentation
- 🥋 **[api-tests/README.md](api-tests/README.md)**: API tests documentation

## Prerequisites

| Tool | Version | Purpose |
|------|---------|---------|
| **Git** | 2.x+ | Version control |
| **Node.js** | 20.x+ | UI tests runtime |
| **Java** | 17+ | API tests runtime |
| **Maven** | 3.9.x+ | Java build tool |
| **Docker** | 24.x+ | Demo app container |
| **ripgrep** | Latest | Non-English audit |
| **cspell** | Latest | Spelling enforcement |

See [RUNBOOK.md](RUNBOOK.md) Section 3 for OS-specific installation instructions.

## Quick Start (60 Seconds)

### 1. Install Prerequisites

**Windows (winget)**:
```cmd
winget install Git.Git OpenJS.NodeJS.LTS EclipseAdoptium.Temurin.17.JDK Apache.Maven Docker.DockerDesktop BurntSushi.ripgrep
npm install -g cspell
```

**macOS (Homebrew)**:
```bash
brew install git node@20 openjdk@17 maven ripgrep
brew install --cask docker
npm install -g cspell
```

**Linux (Ubuntu)**:
```bash
sudo apt update && sudo apt install -y git nodejs npm openjdk-17-jdk maven docker.io ripgrep
npm install -g cspell
```

### 2. Start Demo App

```bash
docker run -d --name demo-app -p 3100:3100 automaticbytes/demo-app:latest
```

### 3. Run UI Tests

```bash
cd ui-tests
npm install
npx playwright install
npm test
```

### 4. Run API Tests

```bash
cd api-tests
mvn clean test
```

## Project Structure

```
qu-challenge/
├── ui-tests/                    # UI automation tests
│   ├── pages/                   # Page Object Models
│   ├── tests/                   # Test specifications
│   ├── playwright.config.ts     # Playwright configuration
│   └── README.md                # UI tests documentation
├── api-tests/                   # API automation tests
│   ├── src/test/resources/      # Karate features
│   │   └── features/            # Test scenarios
│   ├── pom.xml                  # Maven configuration
│   └── README.md                # API tests documentation
├── security/                    # Security testing configs
│   └── zap-baseline.conf        # OWASP ZAP configuration
├── scripts/                     # Helper scripts
│   ├── run-tests.sh             # Unix test runner
│   └── run-tests.bat            # Windows test runner
├── docker-compose.yml           # Orchestration for all services
├── RUNBOOK.md                   # Complete setup and execution guide
├── DELIVERABLES.md              # Deliverables checklist
└── README.md                    # This file
```

## Demo Application

- **UI**: http://localhost:3100
- **API**: http://localhost:3100/api
- **Health**: http://localhost:3100/health

### Key Pages

| Page | URL | Purpose |
|------|-----|---------|
| Login | `/login` | User authentication |
| Checkout | `/checkout` | Purchase flow |
| Grid | `/grid` | Data table with filters |
| Search | `/search` | Search functionality |

### Key API Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/inventory` | GET | List all items |
| `/api/inventory?filter=available` | GET | Filter items |
| `/api/inventory` | POST | Add new item |

## English Language Enforcement

### Spelling Guard (cspell)

**UI Tests**:
```bash
cd ui-tests
npm run spell
```

**API Tests**:
```bash
cd api-tests
npx cspell "src/**/*.{java,feature,md}"
```

### Non-English Content Audit (ripgrep)

```bash
# Search for non-English characters and words
rg -i "á|é|í|ó|ú|ñ|ü|¿|¡|hola|mundo|gracias" --type ts --type js --type java --type md
```

## Quality Gates

### UI Tests (TypeScript)

```bash
cd ui-tests
npm run lint          # ESLint check
npm run lint:fix      # ESLint auto-fix
npm run format        # Prettier format
npm run format:check  # Prettier check
npm run spell         # cspell check
npm run type-check    # TypeScript check
```

### API Tests (Java)

```bash
cd api-tests
mvn spotless:apply    # Format code
mvn checkstyle:check  # Style check
mvn spotbugs:check    # Static analysis
npx cspell "src/**/*" # Spell check
```

## CI/CD

Both repositories include GitHub Actions workflows that run on:
- **OS matrix**: Ubuntu, macOS, Windows
- **Browser matrix** (UI only): Chromium, Firefox, WebKit
- **Triggers**: Push to `main`/`develop`, Pull Requests

### View CI Results

- UI Tests: `.github/workflows/ui-tests.yml`
- API Tests: `.github/workflows/api-tests.yml`

## Docker Compose

Run all services together:

```bash
docker-compose up
```

Services:
- `demo-app`: Demo application (port 3100)
- `ui-tests`: UI test runner
- `api-tests`: API test runner

## Reports

### UI Tests

**HTML Report**:
```bash
cd ui-tests
npx playwright show-report
```

**Allure Report**:
```bash
cd ui-tests
npm run report:allure
```

### API Tests

**Karate Report**:
```bash
cd api-tests
# Windows
start target\karate-reports\karate-summary.html
# macOS
open target/karate-reports/karate-summary.html
# Linux
xdg-open target/karate-reports/karate-summary.html
```

## Security Testing

### OWASP ZAP Baseline Scan

**Windows/macOS**:
```bash
docker run -t owasp/zap2docker-stable zap-baseline.py -t http://host.docker.internal:3100 -r zap-report.html
```

**Linux**:
```bash
docker run -t --network=host owasp/zap2docker-stable zap-baseline.py -t http://localhost:3100 -r zap-report.html
```

## Performance Testing

### Lighthouse CI

```bash
cd ui-tests
npm run lighthouse
```

Checks:
- Performance score > 80
- Accessibility score > 90
- Best practices
- SEO

## Troubleshooting

See [RUNBOOK.md](RUNBOOK.md) Section 11 for OS-specific troubleshooting:

- **Windows**: PATH issues, Docker Desktop, PowerShell quoting
- **macOS**: Xcode CLT, Homebrew permissions, Apple Silicon
- **Linux**: Playwright deps, Docker permissions, SELinux

## Documentation

| Document | Description |
|----------|-------------|
| [RUNBOOK.md](RUNBOOK.md) | Complete cross-platform setup and execution guide |
| [DELIVERABLES.md](DELIVERABLES.md) | Deliverables checklist and project summary |
| [ui-tests/README.md](ui-tests/README.md) | UI tests documentation |
| [api-tests/README.md](api-tests/README.md) | API tests documentation |

## Acceptance Criteria

- [x] All code/comments/docs in professional English
- [x] cspell passes with 0 errors
- [x] ripgrep finds no non-English content
- [x] ESLint/Prettier pass (UI)
- [x] Checkstyle/SpotBugs pass (API)
- [x] Tests pass on Windows/macOS/Linux
- [x] CI workflows green on all OS
- [x] Docker images build successfully
- [x] Reports generated and viewable
- [x] READMEs complete with OS-specific commands

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Commit in English: `git commit -am 'Add my feature'`
4. Push to the branch: `git push origin feature/my-feature`
5. Create a Pull Request

### Commit Message Convention

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types**: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

**Example**:
```
feat(ui): add login page accessibility tests

- Add axe-core scan to login page
- Assert no violations found
- Update README with a11y testing section

Closes #123
```

## License

MIT License. See [LICENSE](LICENSE) file for details.

## Support

- 📧 **Email**: maximiliano.e.alcaraz@gmail.com
- 🐙 **GitHub**: [@AlcarazMaxi](https://github.com/AlcarazMaxi)
- 🐛 **Issues**: [GitHub Issues](https://github.com/AlcarazMaxi/issues)

---

**Built with ❤️ by Maximiliano Alcaraz**

**Happy Testing!** 🎭🥋
