#!/bin/bash
# Unix shell script to run all tests using Docker Compose

echo "Starting test execution with Docker Compose..."

# Check if Docker is running
if ! docker version >/dev/null 2>&1; then
    echo "Error: Docker is not running. Please start Docker."
    exit 1
fi

# Check if docker-compose is available
if ! docker-compose --version >/dev/null 2>&1; then
    echo "Error: docker-compose is not available. Please install Docker Compose."
    exit 1
fi

# Create necessary directories
mkdir -p ui-tests/reports ui-tests/screenshots ui-tests/traces ui-tests/videos
mkdir -p api-tests/target
mkdir -p security-reports

echo "Building and starting services..."
docker-compose up --build --abort-on-container-exit

echo "Test execution completed."
echo "Reports are available in:"
echo "- UI Tests: ui-tests/reports/"
echo "- API Tests: api-tests/target/surefire-reports/"
echo "- Security: security-reports/"

# Clean up containers
echo "Cleaning up containers..."
docker-compose down

echo "All done!"
