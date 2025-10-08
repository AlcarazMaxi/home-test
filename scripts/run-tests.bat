@echo off
REM Windows batch script to run all tests using Docker Compose

echo Starting test execution with Docker Compose...

REM Check if Docker is running
docker version >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Docker is not running. Please start Docker Desktop.
    exit /b 1
)

REM Check if docker-compose is available
docker-compose --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: docker-compose is not available. Please install Docker Compose.
    exit /b 1
)

REM Create necessary directories
if not exist "ui-tests\reports" mkdir ui-tests\reports
if not exist "ui-tests\screenshots" mkdir ui-tests\screenshots
if not exist "ui-tests\traces" mkdir ui-tests\traces
if not exist "ui-tests\videos" mkdir ui-tests\videos
if not exist "api-tests\target" mkdir api-tests\target
if not exist "security-reports" mkdir security-reports

echo Building and starting services...
docker-compose up --build --abort-on-container-exit

echo Test execution completed.
echo Reports are available in:
echo - UI Tests: ui-tests\reports\
echo - API Tests: api-tests\target\surefire-reports\
echo - Security: security-reports\

REM Clean up containers
echo Cleaning up containers...
docker-compose down

echo All done!
pause
