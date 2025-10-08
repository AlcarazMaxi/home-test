# Documentation Index — QA Automation Challenge

## 📚 Complete Documentation Library

This index provides a roadmap to all documentation in this project. Follow the recommended reading order for the best experience.

---

## 🚀 Getting Started (Read First)

| Document | Description | Audience |
|----------|-------------|----------|
| **[README.md](README.md)** | Project overview, quick start, and key features | Everyone |
| **[INSTALLATION_GUIDE.md](INSTALLATION_GUIDE.md)** | Step-by-step installation for Windows/macOS/Linux | Beginners |
| **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** | Common commands cheat sheet | Everyone |

---

## 📖 Detailed Guides

| Document | Description | Audience |
|----------|-------------|----------|
| **[RUNBOOK.md](RUNBOOK.md)** | Complete cross-platform setup and execution guide | Everyone |
| **[ENGLISH_AUDIT_GUIDE.md](ENGLISH_AUDIT_GUIDE.md)** | How to find and fix non-English content | Developers |
| **[ui-tests/README.md](ui-tests/README.md)** | UI tests documentation (Playwright + TypeScript) | UI Testers |
| **[api-tests/README.md](api-tests/README.md)** | API tests documentation (Karate + Java) | API Testers |

---

## 📝 Project Artifacts

| Document | Description | Audience |
|----------|-------------|----------|
| **[DELIVERABLES.md](DELIVERABLES.md)** | Original deliverables checklist | Project Managers |
| **[DELIVERABLES_SUMMARY.md](DELIVERABLES_SUMMARY.md)** | Detailed deliverables summary with time tracking | Project Managers |

---

## 🔧 Technical Configuration

| File | Description | Audience |
|------|-------------|----------|
| **[ui-tests/playwright.config.ts](ui-tests/playwright.config.ts)** | Playwright configuration | UI Testers |
| **[ui-tests/tsconfig.json](ui-tests/tsconfig.json)** | TypeScript configuration | Developers |
| **[ui-tests/.eslintrc.js](ui-tests/.eslintrc.js)** | ESLint configuration | Developers |
| **[ui-tests/cspell.config.cjs](ui-tests/cspell.config.cjs)** | Spell checker configuration | Developers |
| **[api-tests/pom.xml](api-tests/pom.xml)** | Maven configuration | API Testers |
| **[api-tests/cspell.config.cjs](api-tests/cspell.config.cjs)** | Spell checker configuration | Developers |

---

## 🐳 Docker & CI/CD

| File | Description | Audience |
|------|-------------|----------|
| **[docker-compose.yml](docker-compose.yml)** | Multi-service orchestration | DevOps |
| **[ui-tests/Dockerfile](ui-tests/Dockerfile)** | UI test runner container | DevOps |
| **[api-tests/Dockerfile](api-tests/Dockerfile)** | API test runner container | DevOps |
| **[ui-tests/.github/workflows/ui-tests.yml](ui-tests/.github/workflows/ui-tests.yml)** | UI tests CI pipeline | DevOps |
| **[api-tests/.github/workflows/api-tests.yml](api-tests/.github/workflows/api-tests.yml)** | API tests CI pipeline | DevOps |

---

## 🛠️ Helper Scripts

| Script | Description | OS |
|--------|-------------|-----|
| **[scripts/verify-prerequisites.ps1](scripts/verify-prerequisites.ps1)** | Verify all prerequisites are installed | Windows (PowerShell) |
| **[scripts/verify-prerequisites.sh](scripts/verify-prerequisites.sh)** | Verify all prerequisites are installed | macOS/Linux (Bash) |
| **[scripts/run-tests.bat](scripts/run-tests.bat)** | Run all tests with Docker Compose | Windows (CMD) |
| **[scripts/run-tests.sh](scripts/run-tests.sh)** | Run all tests with Docker Compose | macOS/Linux (Bash) |

---

## 🎯 Recommended Reading Order

### For Beginners (Never run automation tests before)

1. **[README.md](README.md)** — Start here to understand the project
2. **[INSTALLATION_GUIDE.md](INSTALLATION_GUIDE.md)** — Install all prerequisites step-by-step
3. Run **[scripts/verify-prerequisites.ps1](scripts/verify-prerequisites.ps1)** or **[scripts/verify-prerequisites.sh](scripts/verify-prerequisites.sh)** — Verify your setup
4. **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** — Keep this handy for common commands
5. **[ui-tests/README.md](ui-tests/README.md)** — Run your first UI tests
6. **[api-tests/README.md](api-tests/README.md)** — Run your first API tests

### For Experienced QA Engineers

1. **[README.md](README.md)** — Project overview
2. **[RUNBOOK.md](RUNBOOK.md)** — Comprehensive setup and execution guide
3. **[ui-tests/README.md](ui-tests/README.md)** and **[api-tests/README.md](api-tests/README.md)** — Deep dive into test frameworks
4. **[ENGLISH_AUDIT_GUIDE.md](ENGLISH_AUDIT_GUIDE.md)** — Learn how to enforce English language quality
5. **[DELIVERABLES_SUMMARY.md](DELIVERABLES_SUMMARY.md)** — Review project deliverables

### For DevOps/CI Engineers

1. **[README.md](README.md)** — Project overview
2. **[docker-compose.yml](docker-compose.yml)** — Multi-service orchestration
3. **[ui-tests/.github/workflows/ui-tests.yml](ui-tests/.github/workflows/ui-tests.yml)** — UI tests CI pipeline
4. **[api-tests/.github/workflows/api-tests.yml](api-tests/.github/workflows/api-tests.yml)** — API tests CI pipeline
5. **[RUNBOOK.md](RUNBOOK.md)** Section 10 — CI/CD details

### For Project Managers

1. **[README.md](README.md)** — Project overview
2. **[DELIVERABLES_SUMMARY.md](DELIVERABLES_SUMMARY.md)** — Detailed deliverables, time tracking, risks
3. **[DELIVERABLES.md](DELIVERABLES.md)** — Original checklist
4. **[RUNBOOK.md](RUNBOOK.md)** Section 12 — Acceptance criteria

---

## 📊 Quick Stats

| Metric | Value |
|--------|-------|
| **Total Documentation Files** | 15+ |
| **Lines of Code (Tests)** | 2,000+ |
| **Lines of Documentation** | 5,000+ |
| **Supported OS** | Windows, macOS, Linux (Ubuntu, Fedora, Arch) |
| **Supported Browsers** | Chromium, Firefox, WebKit |
| **Test Scenarios** | 20+ (UI + API) |
| **Time to Complete** | 42 hours |

---

## 🎯 Use Cases

### "I just joined the team and need to run tests"
→ Follow **[INSTALLATION_GUIDE.md](INSTALLATION_GUIDE.md)** → Run **[scripts/verify-prerequisites.sh](scripts/verify-prerequisites.sh)** → Read **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)**

### "I want to add a new UI test"
→ Read **[ui-tests/README.md](ui-tests/README.md)** → Study existing tests in `ui-tests/tests/` → Follow the Page Object Model pattern

### "I want to add a new API test"
→ Read **[api-tests/README.md](api-tests/README.md)** → Study existing features in `api-tests/src/test/resources/features/` → Write Gherkin scenarios

### "I need to set up CI/CD"
→ Read **[RUNBOOK.md](RUNBOOK.md)** Section 10 → Copy workflows from `ui-tests/.github/workflows/` and `api-tests/.github/workflows/`

### "I found Spanish text in the code"
→ Read **[ENGLISH_AUDIT_GUIDE.md](ENGLISH_AUDIT_GUIDE.md)** → Run `rg -i "á|é|í|ó|ú|ñ"` → Follow the refactoring guide

### "I want to understand the project deliverables"
→ Read **[DELIVERABLES_SUMMARY.md](DELIVERABLES_SUMMARY.md)** → Review checklist in **[DELIVERABLES.md](DELIVERABLES.md)**

### "I need to troubleshoot an issue"
→ Read **[RUNBOOK.md](RUNBOOK.md)** Section 11 (Troubleshooting) → Check OS-specific solutions

### "I want to see a quick command reference"
→ Keep **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** open → Print it for your desk

---

## 📞 Support

| Resource | Description |
|----------|-------------|
| **GitHub Issues** | Report bugs or request features |
| **README.md** | General project information |
| **RUNBOOK.md** | Comprehensive troubleshooting |
| **Email** | maximiliano.e.alcaraz@gmail.com |

---

## 🏆 Quality Standards

All documentation in this project follows these standards:

- ✅ **Professional English only** (enforced with cspell)
- ✅ **Cross-platform commands** (Windows, macOS, Linux)
- ✅ **Line-by-line code comments** (for all code samples)
- ✅ **Beginner-friendly** (assumes no prior knowledge)
- ✅ **Copy-paste ready** (all commands work as-is)
- ✅ **Verified** (all commands tested on target OS)

---

## 📜 License

MIT License. See [LICENSE](LICENSE) file for details.

---

**Last Updated**: October 7, 2025  
**Version**: 1.0  
**Maintained by**: QA Automation Team

**Happy Testing!** 🎭🥋

