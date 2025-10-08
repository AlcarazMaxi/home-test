# Quick Reference Card — Common Commands

## Demo App

### Start
```bash
docker run -d --name demo-app -p 3100:3100 automaticbytes/demo-app:latest
```

### Health Check
```bash
curl http://localhost:3100/health
```

### Stop
```bash
docker stop demo-app && docker rm -f demo-app
```

---

## UI Tests (Playwright + TypeScript)

### Setup
```bash
cd ui-tests
npm install
npx playwright install        # Windows/macOS
npx playwright install --with-deps  # Linux
```

### Run Tests
```bash
npm test                      # All tests (headless)
npm run test:headed           # All tests (headed)
npm run test:chrome           # Chromium only
npm run test:firefox          # Firefox only
npm run test:webkit           # WebKit only
npm run test:smoke            # Smoke tests only
npm run test:debug            # Debug mode
npm run test:ui               # UI mode (interactive)
```

### View Reports
```bash
npm run report                # Open HTML report
npm run report:allure         # Open Allure report
```

### Quality Gates
```bash
npm run lint                  # ESLint check
npm run lint:fix              # ESLint fix
npm run format                # Prettier format
npm run format:check          # Prettier check
npm run spell                 # cspell check
npm run type-check            # TypeScript check
```

---

## API Tests (Karate + Java + Maven)

### Run Tests

**Windows (CMD)**:
```cmd
cd api-tests
mvn clean test
mvn test -Dkarate.options="--tags @smoke"
```

**Windows (PowerShell)**:
```powershell
cd api-tests
mvn clean test
mvn test "-Dkarate.options=--tags @smoke"
```

**macOS/Linux**:
```bash
cd api-tests
mvn clean test
mvn test -Dkarate.options="--tags @smoke"
```

### View Reports

**Windows (CMD)**:
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

### Quality Gates
```bash
mvn spotless:apply            # Format code
mvn checkstyle:check          # Style check
mvn spotbugs:check            # Static analysis
npx cspell "src/**/*"         # Spell check
```

---

## English Audit

### Find Non-English Content
```bash
# Spanish characters
rg -i "á|é|í|ó|ú|ñ|ü|¿|¡"

# Common Spanish words
rg -i "\b(hola|mundo|gracias|nombre|contraseña)\b"
```

### Spell Check
```bash
# UI tests
cd ui-tests && npm run spell

# API tests
cd api-tests && npx cspell "src/**/*.{java,feature,md}"
```

---

## Docker Compose

### Start All Services
```bash
docker-compose up -d
```

### View Logs
```bash
docker-compose logs -f
```

### Stop All Services
```bash
docker-compose down
```

---

## Git

### Commit (English)
```bash
git add .
git commit -m "feat(ui): add login accessibility tests"
git push origin feature/my-feature
```

---

## Troubleshooting

### Windows

**Port in use**:
```cmd
netstat -ano | findstr :3100
taskkill /PID <PID> /F
```

**Docker not running**:
- Start Docker Desktop from Start Menu

### macOS

**Port in use**:
```bash
lsof -ti:3100 | xargs kill -9
```

**Docker not running**:
- Open Docker Desktop app

### Linux

**Port in use**:
```bash
sudo lsof -ti:3100 | xargs sudo kill -9
```

**Docker not running**:
```bash
sudo systemctl start docker
```

**Docker permission denied**:
```bash
sudo usermod -aG docker $USER
newgrp docker
```

---

## CI/CD

### View Workflows
- UI Tests: `.github/workflows/ui-tests.yml`
- API Tests: `.github/workflows/api-tests.yml`

### Trigger Manually
- Go to Actions tab in GitHub
- Select workflow
- Click "Run workflow"

---

## Documentation

| Document | Description |
|----------|-------------|
| [README.md](README.md) | Project overview |
| [RUNBOOK.md](RUNBOOK.md) | Complete setup guide |
| [ENGLISH_AUDIT_GUIDE.md](ENGLISH_AUDIT_GUIDE.md) | How to audit/fix non-English content |
| [DELIVERABLES_SUMMARY.md](DELIVERABLES_SUMMARY.md) | Deliverables checklist |
| [ui-tests/README.md](ui-tests/README.md) | UI tests docs |
| [api-tests/README.md](api-tests/README.md) | API tests docs |

---

## Keyboard Shortcuts (Cursor/VS Code)

| Shortcut | Action |
|----------|--------|
| `Ctrl+Shift+H` (Win/Linux) / `Cmd+Shift+H` (Mac) | Find and replace |
| `Ctrl+P` (Win/Linux) / `Cmd+P` (Mac) | Quick file open |
| `Ctrl+Shift+P` (Win/Linux) / `Cmd+Shift+P` (Mac) | Command palette |
| `F5` | Start debugging |
| `Ctrl+`` ` | Toggle terminal |

---

**Print this card and keep it handy!** 📋

