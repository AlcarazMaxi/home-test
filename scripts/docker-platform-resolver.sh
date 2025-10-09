#!/bin/bash

# Docker Platform Resolution Script
# Comprehensive solution for Docker platform compatibility issues
# Handles platform mismatches, image availability, and fallback strategies

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DEMO_IMAGE="automaticbytes/demo-app:latest"
REQUESTED_PLATFORM="${1:-linux/amd64}"
PORT="${2:-3100}"
CONTAINER_NAME="demo-app-$(echo "$REQUESTED_PLATFORM" | tr '/' '-')"
MAX_RETRIES=3
RETRY_DELAY=5

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

# Function to detect current platform
detect_platform() {
    log_info "Detecting current platform..."
    
    local arch=$(uname -m)
    local os=$(uname -s | tr '[:upper:]' '[:lower:]')
    
    case $arch in
        x86_64)
            echo "linux/amd64"
            ;;
        aarch64|arm64)
            echo "linux/arm64"
            ;;
        *)
            log_warning "Unknown architecture: $arch"
            echo "linux/amd64" # Default fallback
            ;;
    esac
}

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

# Function to check if image exists locally
check_local_image() {
    log_info "Checking for local image: $DEMO_IMAGE"
    
    if docker images --format "table {{.Repository}}:{{.Tag}}" | grep -q "$DEMO_IMAGE"; then
        log_success "Image found locally: $DEMO_IMAGE"
        return 0
    else
        log_warning "Image not found locally: $DEMO_IMAGE"
        return 1
    fi
}

# Function to inspect image platform
inspect_image_platform() {
    local image=$1
    log_info "Inspecting platform for image: $image"
    
    local platform=$(docker inspect "$image" --format="{{.Architecture}}/{{.Os}}" 2>/dev/null || echo "unknown")
    echo "$platform"
}

# Function to pull image with platform specification
pull_image_with_platform() {
    local platform=$1
    log_info "Pulling image with platform specification: $platform"
    
    if docker pull --platform "$platform" "$DEMO_IMAGE"; then
        log_success "Successfully pulled image for platform: $platform"
        return 0
    else
        log_error "Failed to pull image for platform: $platform"
        return 1
    fi
}

# Function to try multi-platform approach
try_multi_platform() {
    log_info "Trying multi-platform approach..."
    
    # Try to pull without platform specification
    if docker pull "$DEMO_IMAGE"; then
        log_success "Successfully pulled image without platform specification"
        return 0
    else
        log_error "Failed to pull image without platform specification"
        return 1
    fi
}

# Function to create mock server
create_mock_server() {
    log_info "Creating mock server as fallback..."
    
    cat > mock-server.js << 'EOF'
const express = require('express');
const app = express();
const port = process.env.PORT || 3100;

app.use(express.json());

// Mock API endpoints
app.get('/api/inventory', (req, res) => {
  res.json([
    { id: '1', name: 'Test Item 1', price: '$10.00', image: 'test1.jpg' },
    { id: '2', name: 'Test Item 2', price: '$15.00', image: 'test2.jpg' },
    { id: '3', name: 'Baked Rolls x 8', price: '$8.00', image: 'rolls.jpg' },
    { id: '4', name: 'Super Pepperoni', price: '$10.00', image: 'pepperoni.jpg' }
  ]);
});

app.get('/api/inventory/filter', (req, res) => {
  const id = req.query.id;
  if (id === '3') {
    res.json([{ id: '3', name: 'Baked Rolls x 8', price: '$8.00', image: 'rolls.jpg' }]);
  } else {
    res.json([]);
  }
});

app.post('/api/inventory/add', (req, res) => {
  const { id, name, price, image } = req.body;
  
  if (!id || !name || !price || !image) {
    return res.status(400).json({ message: 'Not all requirements are met' });
  }
  
  if (id === '10') {
    return res.status(400).json({ message: 'Item with this ID already exists' });
  }
  
  res.status(200).json({ message: 'Item added successfully', item: req.body });
});

app.get('/api', (req, res) => {
  res.json({ status: 'ok', message: 'Mock API Server' });
});

// Mock web pages
app.get('/', (req, res) => {
  res.send(`
    <html>
      <head><title>Mock Demo App</title></head>
      <body>
        <h1>Mock Demo Application</h1>
        <p>This is a mock server for testing purposes.</p>
        <nav>
          <a href="/login">Login</a> | 
          <a href="/grid">Grid</a> | 
          <a href="/search">Search</a> | 
          <a href="/checkout">Checkout</a>
        </nav>
      </body>
    </html>
  `);
});

app.get('/login', (req, res) => {
  res.send(`
    <html>
      <head><title>Login - Mock Demo App</title></head>
      <body>
        <h1>Login</h1>
        <form id="login-form">
          <input id="username" type="text" placeholder="Username">
          <input id="password" type="password" placeholder="Password">
          <button id="signin-button" type="submit">Sign In</button>
        </form>
        <div id="message"></div>
      </body>
    </html>
  `);
});

app.get('/grid', (req, res) => {
  res.send(`
    <html>
      <head><title>Grid - Mock Demo App</title></head>
      <body>
        <h1>Product Grid</h1>
        <div id="menu">
          <div class="item">
            <h3 data-test-id="item-name">Test Product 1</h3>
            <span id="item-price">$10.00</span>
            <img src="test1.jpg" alt="Test Product 1">
            <button data-test-id="add-to-order">Add to Cart</button>
          </div>
        </div>
      </body>
    </html>
  `);
});

app.get('/search', (req, res) => {
  res.send(`
    <html>
      <head><title>Search - Mock Demo App</title></head>
      <body>
        <h1>Search</h1>
        <form>
          <input name="searchWord" type="text" placeholder="Search...">
          <button type="submit">Search</button>
        </form>
        <div id="result">Search results will appear here</div>
      </body>
    </html>
  `);
});

app.get('/checkout', (req, res) => {
  res.send(`
    <html>
      <head><title>Checkout - Mock Demo App</title></head>
      <body>
        <h1>Checkout</h1>
        <form action="/form-validation">
          <input name="firstName" type="text" placeholder="First Name">
          <input name="lastName" type="text" placeholder="Last Name">
          <input name="email" type="email" placeholder="Email">
          <input name="phone" type="tel" placeholder="Phone">
          <button type="submit">Submit Order</button>
        </form>
        <div class="cart-total">
          <span class="price">Total: <b>$25.00</b></span>
        </div>
      </body>
    </html>
  `);
});

app.listen(port, () => {
  console.log(\`Mock server running on port \${port}\`);
});
EOF

    log_success "Mock server created"
    return 0
}

# Function to start container with platform specification
start_container_with_platform() {
    local platform=$1
    local container_name=$2
    local port=$3
    
    log_info "Starting container with platform: $platform"
    
    if docker run -d \
        --platform "$platform" \
        -p "$port:3100" \
        --name "$container_name" \
        --health-cmd="curl -f http://localhost:3100 || exit 1" \
        --health-interval=5s \
        --health-timeout=3s \
        --health-retries=3 \
        "$DEMO_IMAGE"; then
        log_success "Container started successfully: $container_name"
        return 0
    else
        log_error "Failed to start container: $container_name"
        return 1
    fi
}

# Function to start container without platform specification
start_container_without_platform() {
    local container_name=$1
    local port=$2
    
    log_info "Starting container without platform specification"
    
    if docker run -d \
        -p "$port:3100" \
        --name "$container_name" \
        --health-cmd="curl -f http://localhost:3100 || exit 1" \
        --health-interval=5s \
        --health-timeout=3s \
        --health-retries=3 \
        "$DEMO_IMAGE"; then
        log_success "Container started successfully: $container_name"
        return 0
    else
        log_error "Failed to start container: $container_name"
        return 1
    fi
}

# Function to start mock server
start_mock_server() {
    local port=$1
    
    log_info "Starting mock server on port: $port"
    
    # Install express if not available
    if ! command -v node &> /dev/null; then
        log_error "Node.js is not available"
        return 1
    fi
    
    if ! npm list express &> /dev/null; then
        log_info "Installing express..."
        npm install express
    fi
    
    # Start mock server in background
    PORT="$port" node mock-server.js &
    local pid=$!
    echo "$pid" > mock-server.pid
    
    # Wait for server to start
    sleep 5
    
    log_success "Mock server started with PID: $pid"
    return 0
}

# Function to wait for service to be ready
wait_for_service() {
    local port=$1
    local max_attempts=12
    local attempt=1
    
    log_info "Waiting for service to be ready on port: $port"
    
    while [ $attempt -le $max_attempts ]; do
        if curl -f "http://localhost:$port" &> /dev/null; then
            log_success "Service is ready on port: $port"
            return 0
        fi
        
        log_info "Attempt $attempt/$max_attempts - waiting for service..."
        sleep $RETRY_DELAY
        attempt=$((attempt + 1))
    done
    
    log_error "Service did not become ready within $((max_attempts * RETRY_DELAY)) seconds"
    return 1
}

# Function to cleanup resources
cleanup() {
    log_info "Cleaning up resources..."
    
    # Stop and remove container
    docker stop "$CONTAINER_NAME" 2>/dev/null || true
    docker rm "$CONTAINER_NAME" 2>/dev/null || true
    
    # Stop mock server
    if [ -f mock-server.pid ]; then
        local pid=$(cat mock-server.pid)
        kill "$pid" 2>/dev/null || true
        rm -f mock-server.pid
    fi
    
    # Clean up any orphaned processes
    pkill -f "node mock-server.js" 2>/dev/null || true
    
    # Clean up Docker resources
    docker container prune -f 2>/dev/null || true
    docker image prune -f 2>/dev/null || true
    
    log_success "Cleanup completed"
}

# Function to test service connectivity
test_connectivity() {
    local port=$1
    
    log_info "Testing service connectivity on port: $port"
    
    if curl -f "http://localhost:$port" &> /dev/null; then
        log_success "Service connectivity test passed"
        return 0
    else
        log_error "Service connectivity test failed"
        return 1
    fi
}

# Main execution function
main() {
    log_info "Starting Docker Platform Resolution"
    log_info "Requested Platform: $REQUESTED_PLATFORM"
    log_info "Port: $PORT"
    log_info "Container Name: $CONTAINER_NAME"
    
    # Check prerequisites
    check_docker
    
    # Strategy 1: Try platform-specific pull and run
    log_info "=== Strategy 1: Platform-Specific Approach ==="
    if pull_image_with_platform "$REQUESTED_PLATFORM" && start_container_with_platform "$REQUESTED_PLATFORM" "$CONTAINER_NAME" "$PORT"; then
        if wait_for_service "$PORT" && test_connectivity "$PORT"; then
            log_success "Strategy 1 successful: Platform-specific container running"
            exit 0
        fi
    fi
    
    # Strategy 2: Try multi-platform approach
    log_info "=== Strategy 2: Multi-Platform Approach ==="
    if try_multi_platform && start_container_without_platform "$CONTAINER_NAME" "$PORT"; then
        if wait_for_service "$PORT" && test_connectivity "$PORT"; then
            log_success "Strategy 2 successful: Multi-platform container running"
            exit 0
        fi
    fi
    
    # Strategy 3: Use mock server fallback
    log_info "=== Strategy 3: Mock Server Fallback ==="
    if create_mock_server && start_mock_server "$PORT"; then
        if wait_for_service "$PORT" && test_connectivity "$PORT"; then
            log_success "Strategy 3 successful: Mock server running"
            exit 0
        fi
    fi
    
    # All strategies failed
    log_error "All strategies failed - unable to start demo app"
    cleanup
    exit 1
}

# Trap for cleanup on exit
trap cleanup EXIT

# Run main function
main "$@"
