#!/bin/bash

# Docker Platform Compatibility Validation Script
# Comprehensive testing for Docker platform compatibility issues
# Designed to prevent CI/CD failures and ensure cross-platform support

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Configuration
PLATFORMS=("linux/amd64" "linux/arm64")
DEMO_IMAGE="automaticbytes/demo-app:latest"
TEST_TIMEOUT=60
MAX_RETRIES=3

# Function to check Docker availability
check_docker() {
    log_info "Checking Docker availability..."
    
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed or not in PATH"
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        log_error "Docker daemon is not running"
        exit 1
    fi
    
    log_success "Docker is available and running"
}

# Function to check Docker Buildx
check_docker_buildx() {
    log_info "Checking Docker Buildx availability..."
    
    if ! docker buildx version &> /dev/null; then
        log_warning "Docker Buildx not available, installing..."
        docker buildx install || {
            log_error "Failed to install Docker Buildx"
            exit 1
        }
    fi
    
    # Check if buildx is available
    if ! docker buildx ls &> /dev/null; then
        log_error "Docker Buildx is not properly configured"
        exit 1
    fi
    
    log_success "Docker Buildx is available"
}

# Function to check QEMU for multi-platform support
check_qemu() {
    log_info "Checking QEMU support..."
    
    # Check if QEMU is available for multi-platform builds
    if ! docker run --rm --privileged multiarch/qemu-user-static --reset -p yes &> /dev/null; then
        log_warning "QEMU not available for multi-platform builds"
        log_info "Installing QEMU support..."
        
        # Install QEMU support
        docker run --rm --privileged multiarch/qemu-user-static --reset -p yes || {
            log_warning "QEMU installation failed, continuing with single platform"
        }
    fi
    
    log_success "QEMU support is available"
}

# Function to test platform compatibility
test_platform_compatibility() {
    local platform=$1
    log_info "Testing platform compatibility: $platform"
    
    # Test pulling image for specific platform
    log_info "Pulling demo image for platform: $platform"
    if ! docker pull --platform "$platform" "$DEMO_IMAGE"; then
        log_error "Failed to pull demo image for platform: $platform"
        return 1
    fi
    
    # Test running container for specific platform
    log_info "Testing container startup for platform: $platform"
    local container_name="test-demo-app-$(echo "$platform" | tr '/' '-')"
    
    if ! docker run -d \
        --platform "$platform" \
        --name "$container_name" \
        -p 3100:3100 \
        --health-cmd="curl -f http://localhost:3100 || exit 1" \
        --health-interval=5s \
        --health-timeout=3s \
        --health-retries=3 \
        "$DEMO_IMAGE"; then
        log_error "Failed to start container for platform: $platform"
        return 1
    fi
    
    # Wait for container to be healthy
    log_info "Waiting for container to be healthy..."
    local retry_count=0
    while [ $retry_count -lt $MAX_RETRIES ]; do
        if docker inspect "$container_name" --format="{{.State.Health.Status}}" | grep -q "healthy"; then
            log_success "Container is healthy for platform: $platform"
            break
        fi
        
        retry_count=$((retry_count + 1))
        log_info "Waiting for health check... (attempt $retry_count/$MAX_RETRIES)"
        sleep 10
    done
    
    if [ $retry_count -eq $MAX_RETRIES ]; then
        log_error "Container failed to become healthy for platform: $platform"
        docker logs "$container_name"
        docker stop "$container_name" || true
        docker rm "$container_name" || true
        return 1
    fi
    
    # Test API connectivity
    log_info "Testing API connectivity for platform: $platform"
    if ! curl -f http://localhost:3100/api; then
        log_error "API connectivity failed for platform: $platform"
        docker logs "$container_name"
        docker stop "$container_name" || true
        docker rm "$container_name" || true
        return 1
    fi
    
    log_success "API connectivity successful for platform: $platform"
    
    # Cleanup
    log_info "Cleaning up container for platform: $platform"
    docker stop "$container_name" || true
    docker rm "$container_name" || true
    
    log_success "Platform compatibility test passed for: $platform"
    return 0
}

# Function to test Docker Compose
test_docker_compose() {
    log_info "Testing Docker Compose compatibility..."
    
    if ! command -v docker-compose &> /dev/null; then
        log_warning "Docker Compose not available, testing with docker compose"
        if ! docker compose version &> /dev/null; then
            log_error "Neither docker-compose nor docker compose is available"
            return 1
        fi
        COMPOSE_CMD="docker compose"
    else
        COMPOSE_CMD="docker-compose"
    fi
    
    log_success "Docker Compose is available: $COMPOSE_CMD"
    
    # Test compose file syntax
    if [ -f "docker-compose.principal.yml" ]; then
        log_info "Validating Docker Compose file syntax..."
        if ! $COMPOSE_CMD -f docker-compose.principal.yml config &> /dev/null; then
            log_error "Docker Compose file has syntax errors"
            return 1
        fi
        log_success "Docker Compose file syntax is valid"
    fi
}

# Function to run comprehensive tests
run_comprehensive_tests() {
    log_info "Running comprehensive Docker platform compatibility tests..."
    
    local failed_platforms=()
    
    for platform in "${PLATFORMS[@]}"; do
        if ! test_platform_compatibility "$platform"; then
            failed_platforms+=("$platform")
        fi
    done
    
    if [ ${#failed_platforms[@]} -gt 0 ]; then
        log_error "Failed platforms: ${failed_platforms[*]}"
        return 1
    fi
    
    log_success "All platform compatibility tests passed"
    return 0
}

# Function to generate test report
generate_test_report() {
    local report_file="docker-platform-test-report-$(date +%Y%m%d-%H%M%S).txt"
    
    log_info "Generating test report: $report_file"
    
    {
        echo "Docker Platform Compatibility Test Report"
        echo "=========================================="
        echo "Date: $(date)"
        echo "OS: $(uname -a)"
        echo "Docker Version: $(docker version --format '{{.Server.Version}}')"
        echo "Docker Buildx Version: $(docker buildx version)"
        echo ""
        echo "Test Results:"
        echo "-------------"
        
        for platform in "${PLATFORMS[@]}"; do
            if test_platform_compatibility "$platform" &> /dev/null; then
                echo "✅ $platform: PASSED"
            else
                echo "❌ $platform: FAILED"
            fi
        done
        
        echo ""
        echo "Docker Info:"
        echo "-----------"
        docker info
        
    } > "$report_file"
    
    log_success "Test report generated: $report_file"
}

# Main execution
main() {
    log_info "Starting Docker Platform Compatibility Validation"
    log_info "=================================================="
    
    # Check prerequisites
    check_docker
    check_docker_buildx
    check_qemu
    test_docker_compose
    
    # Run comprehensive tests
    if run_comprehensive_tests; then
        log_success "All Docker platform compatibility tests passed!"
        generate_test_report
        exit 0
    else
        log_error "Some Docker platform compatibility tests failed!"
        generate_test_report
        exit 1
    fi
}

# Run main function
main "$@"
