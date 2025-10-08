# Complete Setup Guide

## 🚀 Quick Start (5 Minutes)

### Prerequisites Check
```cmd
REM Check all required tools
git --version
docker --version
node --version
java -version
mvn --version
```

### 1. Start Demo Application
```cmd
REM Pull and run the demo app
docker pull automaticbytes/demo-app
docker run -d -p 3100:3100 --name demo-app automaticbytes/demo-app

REM Verify it's running
curl http://localhost:3100/api/inventory
```

### 2. Setup UI Tests
```cmd
cd ui-tests
npm install
npm run setup
npm run test
```

### 3. Setup API Tests
```cmd
cd api-tests
mvn clean install
mvn test
```

## 📋 Detailed Setup Instructions

### Windows Setup

#### 1. Install Prerequisites
- **Git**: Download from https://git-scm.com/download/win
- **Docker Desktop**: Download from https://www.docker.com/products/docker-desktop
- **Node.js**: Download LTS version from https://nodejs.org/
- **Java 17**: Download from https://adoptium.net/
- **Maven**: Download from https://maven.apache.org/download.cgi

#### 2. Verify Installations
```cmd
REM Check versions
git --version
docker --version
node --version
npm --version
java -version
mvn --version
```

#### 3. Clone and Setup
```cmd
REM Clone the repository
git clone <repository-url>
cd qu-challenge

REM Setup UI tests
cd ui-tests
npm install
npm run setup

REM Setup API tests
cd ../api-tests
mvn clean install
```

### Linux/macOS Setup

#### 1. Install Prerequisites
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install git docker.io nodejs npm openjdk-17-jdk maven

# macOS with Homebrew
brew install git docker node maven openjdk@17
```

#### 2. Verify Installations
```bash
git --version
docker --version
node --version
npm --version
java -version
mvn --version
```

#### 3. Clone and Setup
```bash
# Clone the repository
git clone <repository-url>
cd qu-challenge

# Setup UI tests
cd ui-tests
npm install
chmod +x scripts/setup.sh
./scripts/setup.sh

# Setup API tests
cd ../api-tests
mvn clean install
```

## 🧪 Running Tests

### UI Tests
```cmd
REM Run all tests
npm run test

REM Run specific test suites
npm run test:smoke
npm run test:regression
npm run test:a11y
npm run test:performance

REM Run with specific browser
npm run test:chrome
npm run test:firefox
npm run test:webkit
npm run test:mobile

REM Run in headed mode
npm run test:headed

REM Run with debugging
npm run test:debug
npm run test:ui
```

### API Tests
```cmd
REM Run all tests
mvn test

REM Run specific test suites
mvn test -Dkarate.options="--tags @smoke"
mvn test -Dkarate.options="--tags @regression"

REM Run with specific environment
mvn test -Dkarate.env=dev
mvn test -Dkarate.env=prod

REM Run with parallel execution
mvn test -Dkarate.options="--tags @smoke" -Dparallel=4
```

### Docker Tests
```cmd
REM Run all tests with Docker
docker-compose up --build

REM Run specific services
docker-compose up ui-tests
docker-compose up api-tests
docker-compose up lighthouse
docker-compose up zap
```

## 📊 Viewing Reports

### UI Test Reports
```cmd
REM Open HTML report
npm run report

REM Open Allure report
npm run report:allure

REM View Lighthouse report
open reports/lighthouse/
```

### API Test Reports
```cmd
REM Generate Maven reports
mvn surefire-report:report

REM View reports
open target/surefire-reports/
open target/karate-reports/
```

## 🔧 Troubleshooting

### Common Issues

#### 1. Port 3100 Already in Use
```cmd
REM Check what's using the port
netstat -ano | findstr :3100

REM Kill the process
taskkill /PID <PID> /F

REM Or use a different port
docker run -d -p 3101:3100 --name demo-app automaticbytes/demo-app
```

#### 2. Docker Not Running
```cmd
REM Start Docker Desktop
REM Ensure WSL2 is enabled in Docker Desktop settings
```

#### 3. Node.js Version Issues
```cmd
REM Check Node.js version
node --version

REM Install correct version
nvm install 18
nvm use 18
```

#### 4. Java Version Issues
```cmd
REM Check Java version
java -version

REM Set JAVA_HOME
set JAVA_HOME=C:\Program Files\Java\jdk-17
```

#### 5. Maven Issues
```cmd
REM Check Maven version
mvn --version

REM Clean and rebuild
mvn clean install
```

### Debug Commands

#### UI Tests Debugging
```cmd
REM Run with debugging
npm run test:debug

REM Run with UI mode
npm run test:ui

REM View test traces
npx playwright show-trace traces/test-trace.zip

REM View test videos
start videos/test-video.webm
```

#### API Tests Debugging
```cmd
REM Run with verbose logging
mvn test -X

REM Run single test file
mvn test -Dtest=TestRunner#runSmokeTests

REM View test logs
type target\surefire-reports\*.txt
```

## 🚀 CI/CD Setup

### GitHub Actions
1. Push code to GitHub repository
2. GitHub Actions will automatically run tests
3. View results in Actions tab
4. Download artifacts for reports

### Local CI/CD
```cmd
REM Run full test suite
npm run test:all
mvn test

REM Generate reports
npm run report
mvn surefire-report:report

REM Run security scans
docker run -t owasp/zap2docker-stable zap-baseline.py -t http://localhost:3100
```

## 📈 Performance Optimization

### Test Execution Speed
```cmd
REM Run tests in parallel
npm run test -- --workers=4
mvn test -Dparallel=4

REM Run only smoke tests
npm run test:smoke
mvn test -Dkarate.options="--tags @smoke"
```

### Resource Usage
```cmd
REM Monitor Docker resources
docker stats

REM Monitor system resources
tasklist /fi "imagename eq node.exe"
tasklist /fi "imagename eq java.exe"
```

## 🔒 Security Testing

### OWASP ZAP Scanning
```cmd
REM Run baseline scan
docker run -t owasp/zap2docker-stable zap-baseline.py -t http://localhost:3100

REM Run full scan
docker run -t owasp/zap2docker-stable zap-full-scan.py -t http://localhost:3100

REM View security reports
open security-reports/
```

## 📱 Mobile Testing

### Mobile Emulation
```cmd
REM Run mobile tests
npm run test:mobile

REM Run specific mobile tests
npm run test -- --project=mobile
```

### Responsive Testing
```cmd
REM Test different viewports
npm run test -- --project=tablet
npm run test -- --project=mobile-safari
```

## 🎯 Best Practices

### Test Development
1. **Write Clear Tests**: Use descriptive test names
2. **Use Page Objects**: Maintain reusable page objects
3. **Data-Driven Tests**: Use test data files
4. **Parallel Execution**: Run tests in parallel
5. **Proper Waits**: Use explicit waits instead of sleeps

### Code Quality
1. **Linting**: Run ESLint and Prettier
2. **Type Checking**: Use TypeScript strict mode
3. **Code Reviews**: Review all changes
4. **Documentation**: Keep documentation updated
5. **Version Control**: Use meaningful commit messages

### Maintenance
1. **Regular Updates**: Update dependencies monthly
2. **Test Review**: Review and update tests quarterly
3. **Performance Monitoring**: Monitor test execution times
4. **Flaky Test Management**: Address flaky tests immediately
5. **Documentation Updates**: Keep setup guides current

## 📞 Support

### Getting Help
- **Documentation**: Check README files
- **Issues**: Create GitHub issues
- **Discussions**: Use GitHub discussions
- **Examples**: Review test examples

### Contact
- **Email**: maximiliano.e.alcaraz@gmail.com
- **GitHub**: [@AlcarazMaxi](https://github.com/AlcarazMaxi)

---

**Happy Testing! 🎉**
