#!/bin/bash

# Docker Platform Detection and Compatibility Script
# Production-level platform detection with comprehensive fallback strategies
# Handles architecture mismatches, emulation requirements, and health validation

set -euo pipefail

# Color codes for output
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

# Function to detect runner architecture
detect_runner_architecture() {
    local arch=""
    
    # Check GitHub Actions environment variables
    if [[ -n "${RUNNER_ARCH:-}" ]]; then
        arch="$RUNNER_ARCH"
        log_info "Detected architecture from RUNNER_ARCH: $arch"
    elif [[ -n "${RUNNER_OS:-}" ]]; then
        case "$RUNNER_OS" in
            "Linux")
                arch=$(uname -m)
                ;;
            "Windows")
                arch="x64"
                ;;
            "macOS")
                arch=$(uname -m)
                ;;
        esac
        log_info "Detected architecture from RUNNER_OS: $arch"
    else
        arch=$(uname -m)
        log_info "Detected architecture from uname: $arch"
    fi
    
    # Normalize architecture names
    case "$arch" in
        "x86_64"|"amd64"|"x64")
            echo "linux/amd64"
            ;;
        "aarch64"|"arm64")
            echo "linux/arm64"
            ;;
        *)
            log_warning "Unknown architecture: $arch, defaulting to linux/amd64"
            echo "linux/amd64"
            ;;
    esac
}

# Function to detect Docker platform
detect_docker_platform() {
    if command -v docker >/dev/null 2>&1; then
        local docker_arch
        docker_arch=$(docker version --format '{{.Server.Arch}}' 2>/dev/null || echo "unknown")
        log_info "Docker server architecture: $docker_arch"
        echo "$docker_arch"
    else
        log_error "Docker not available"
        echo "unknown"
    fi
}

# Function to check if QEMU emulation is available
check_qemu_emulation() {
    if command -v docker >/dev/null 2>&1; then
        # Check if QEMU static binaries are available
        if docker run --rm --privileged multiarch/qemu-user-static --version >/dev/null 2>&1; then
            log_success "QEMU emulation is available"
            return 0
        else
            log_warning "QEMU emulation not available"
            return 1
        fi
    else
        log_error "Docker not available for QEMU check"
        return 1
    fi
}

# Function to setup QEMU emulation
setup_qemu_emulation() {
    log_info "Setting up QEMU emulation for cross-platform support..."
    
    # Install QEMU static binaries
    docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
    
    # Setup buildx for multi-platform support
    if ! docker buildx ls | grep -q "multiarch"; then
        docker buildx create --name multiarch --driver docker-container --use
        docker buildx inspect --bootstrap
    fi
    
    log_success "QEMU emulation setup completed"
}

# Function to test Docker image compatibility
test_docker_image() {
    local image="$1"
    local platform="$2"
    local container_name="test-container-$(date +%s)"
    
    log_info "Testing Docker image compatibility: $image on $platform"
    
    # Try to run the image
    if docker run --rm --platform "$platform" --name "$container_name" "$image" --version >/dev/null 2>&1; then
        log_success "Image $image is compatible with platform $platform"
        return 0
    else
        log_warning "Image $image is not compatible with platform $platform"
        return 1
    fi
}

# Function to start Docker container with platform specification
start_docker_container() {
    local image="$1"
    local port="$2"
    local container_name="$3"
    local platform="$4"
    local max_retries="${5:-10}"
    local retry_delay="${6:-3}"
    
    log_info "Starting Docker container: $image on $platform"
    
    # Stop and remove existing container
    docker stop "$container_name" 2>/dev/null || true
    docker rm "$container_name" 2>/dev/null || true
    
    # Start container with explicit platform
    if docker run -d \
        --platform "$platform" \
        -p "$port:$port" \
        --name "$container_name" \
        --health-cmd="curl -f http://localhost:$port || exit 1" \
        --health-interval=5s \
        --health-timeout=3s \
        --health-retries=3 \
        "$image"; then
        
        log_success "Container started successfully"
        
        # Wait for container to be healthy
        local retry_count=0
        while [[ $retry_count -lt $max_retries ]]; do
            if docker ps --filter name="$container_name" --filter health=healthy --format "{{.Status}}" | grep -q "healthy"; then
                log_success "Container is healthy and ready"
                return 0
            elif docker ps --filter name="$container_name" --format "{{.Status}}" | grep -q "unhealthy"; then
                log_error "Container is unhealthy"
                return 1
            fi
            
            log_info "Waiting for container to be ready... (attempt $((retry_count + 1))/$max_retries)"
            sleep $retry_delay
            ((retry_count++))
        done
        
        log_error "Container failed to become healthy within timeout"
        return 1
    else
        log_error "Failed to start container"
        return 1
    fi
}

# Function to validate container health
validate_container_health() {
    local container_name="$1"
    local port="$2"
    local max_retries="${3:-10}"
    local retry_delay="${4:-3}"
    
    log_info "Validating container health: $container_name on port $port"
    
    local retry_count=0
    while [[ $retry_count -lt $max_retries ]]; do
        # Check if container is running
        if ! docker ps --filter name="$container_name" --format "{{.Status}}" | grep -q "Up"; then
            log_error "Container is not running"
            return 1
        fi
        
        # Check if port is accessible
        if curl -f "http://localhost:$port" >/dev/null 2>&1; then
            log_success "Container is healthy and accessible on port $port"
            return 0
        fi
        
        log_info "Waiting for container to be accessible... (attempt $((retry_count + 1))/$max_retries)"
        sleep $retry_delay
        ((retry_count++))
    done
    
    log_error "Container health validation failed"
    return 1
}

# Function to get container logs for debugging
get_container_logs() {
    local container_name="$1"
    
    log_info "Container logs for $container_name:"
    docker logs "$container_name" 2>&1 || log_warning "Could not retrieve container logs"
}

# Function to cleanup container
cleanup_container() {
    local container_name="$1"
    
    log_info "Cleaning up container: $container_name"
    docker stop "$container_name" 2>/dev/null || true
    docker rm "$container_name" 2>/dev/null || true
    log_success "Container cleanup completed"
}

# Main function
main() {
    local image="${1:-automaticbytes/demo-app:latest}"
    local port="${2:-3100}"
    local container_name="${3:-demo-app}"
    
    log_info "Starting Docker platform detection and compatibility check"
    
    # Detect runner architecture
    local runner_arch
    runner_arch=$(detect_runner_architecture)
    log_info "Runner architecture: $runner_arch"
    
    # Detect Docker platform
    local docker_arch
    docker_arch=$(detect_docker_platform)
    log_info "Docker architecture: $docker_arch"
    
    # Check if architectures match
    if [[ "$runner_arch" == "$docker_arch" ]]; then
        log_success "Architectures match - native execution possible"
        local target_platform="$runner_arch"
    else
        log_warning "Architecture mismatch detected"
        
        # Check if QEMU emulation is available
        if check_qemu_emulation; then
            log_info "QEMU emulation available - setting up cross-platform support"
            setup_qemu_emulation
            local target_platform="linux/amd64"  # Default to AMD64 for compatibility
        else
            log_error "QEMU emulation not available - cannot run cross-platform"
            return 1
        fi
    fi
    
    # Test image compatibility
    if test_docker_image "$image" "$target_platform"; then
        log_success "Image compatibility confirmed"
    else
        log_error "Image compatibility test failed"
        return 1
    fi
    
    # Start container with proper platform specification
    if start_docker_container "$image" "$port" "$container_name" "$target_platform"; then
        log_success "Container started successfully with platform $target_platform"
        
        # Validate container health
        if validate_container_health "$container_name" "$port"; then
            log_success "Container is healthy and ready for testing"
            echo "CONTAINER_READY=true"
            echo "CONTAINER_NAME=$container_name"
            echo "CONTAINER_PORT=$port"
            echo "CONTAINER_PLATFORM=$target_platform"
            return 0
        else
            log_error "Container health validation failed"
            get_container_logs "$container_name"
            cleanup_container "$container_name"
            return 1
        fi
    else
        log_error "Failed to start container"
        return 1
    fi
}

# Export functions for use in other scripts
export -f detect_runner_architecture
export -f detect_docker_platform
export -f check_qemu_emulation
export -f setup_qemu_emulation
export -f test_docker_image
export -f start_docker_container
export -f validate_container_health
export -f get_container_logs
export -f cleanup_container

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
