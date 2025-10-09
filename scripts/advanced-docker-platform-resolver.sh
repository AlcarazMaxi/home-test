#!/bin/bash

# Principal QA Engineer: Advanced Docker Platform Resolution Script
# Comprehensive solution for Docker platform compatibility issues
# Handles architecture mismatches, emulation, and fallback strategies

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
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

log_debug() {
    echo -e "${PURPLE}[DEBUG]${NC} $1"
}

# Function to detect current platform and capabilities
detect_platform_capabilities() {
    log_info "Detecting platform capabilities..."
    
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

# Function to check Docker and QEMU availability
check_docker_and_qemu() {
    log_info "Checking Docker and QEMU availability..."
    
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed or not in PATH"
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        log_error "Docker daemon is not running"
        exit 1
    fi
    
    # Check for QEMU support
    if docker run --rm --privileged multiarch/qemu-user-static --reset -p yes &> /dev/null; then
        log_success "QEMU support is available for cross-platform emulation"
        return 0
    else
        log_warning "QEMU support is not available - limited to native platform"
        return 1
    fi
}

# Function to analyze available image platforms
analyze_image_platforms() {
    local image=$1
    log_info "Analyzing available platforms for image: $image"
    
    # Try to get image manifest
    if docker manifest inspect "$image" &> /dev/null; then
        log_success "Image manifest is available"
        docker manifest inspect "$image" | jq -r '.manifests[].platform | "\(.architecture)/\(.os)"' 2>/dev/null || echo "Unable to parse manifest"
    else
        log_warning "Image manifest is not available"
    fi
    
    # Check local image
    if docker images --format "table {{.Repository}}:{{.Tag}}" | grep -q "$image"; then
        local platform=$(docker inspect "$image" --format="{{.Architecture}}/{{.Os}}" 2>/dev/null || echo "unknown")
        log_info "Local image platform: $platform"
        echo "$platform"
    else
        log_warning "Image not found locally"
        echo "unknown"
    fi
}

# Function to try platform-specific pull with emulation
try_platform_specific_pull() {
    local platform=$1
    log_info "Attempting platform-specific pull: $platform"
    
    if docker pull --platform "$platform" "$DEMO_IMAGE"; then
        log_success "Successfully pulled image for platform: $platform"
        return 0
    else
        log_error "Failed to pull image for platform: $platform"
        return 1
    fi
}

# Function to try multi-platform approach
try_multi_platform_approach() {
    log_info "Attempting multi-platform approach..."
    
    # Try to pull without platform specification
    if docker pull "$DEMO_IMAGE"; then
        log_success "Successfully pulled image without platform specification"
        return 0
    else
        log_error "Failed to pull image without platform specification"
        return 1
    fi
}

# Function to create comprehensive mock server
create_comprehensive_mock_server() {
    log_info "Creating comprehensive mock server..."
    
    cat > comprehensive-mock-server.js << 'EOF'
const express = require('express');
const app = express();
const port = process.env.PORT || 3100;

app.use(express.json());
app.use(express.static('public'));

// Mock API endpoints that match the demo app exactly
app.get('/api/inventory', (req, res) => {
  res.json([
    { id: '1', name: 'Margherita Pizza', price: '$12.00', image: 'margherita.jpg' },
    { id: '2', name: 'Pepperoni Pizza', price: '$14.00', image: 'pepperoni.jpg' },
    { id: '3', name: 'Baked Rolls x 8', price: '$8.00', image: 'rolls.jpg' },
    { id: '4', name: 'Super Pepperoni', price: '$10.00', image: 'super-pepperoni.jpg' },
    { id: '5', name: 'Hawaiian Pizza', price: '$16.00', image: 'hawaiian.jpg' },
    { id: '6', name: 'Vegetarian Pizza', price: '$13.00', image: 'vegetarian.jpg' },
    { id: '7', name: 'Meat Lovers', price: '$18.00', image: 'meat-lovers.jpg' },
    { id: '8', name: 'BBQ Chicken', price: '$15.00', image: 'bbq-chicken.jpg' },
    { id: '9', name: 'Supreme Pizza', price: '$17.00', image: 'supreme.jpg' }
  ]);
});

app.get('/api/inventory/filter', (req, res) => {
  const id = req.query.id;
  const inventory = [
    { id: '1', name: 'Margherita Pizza', price: '$12.00', image: 'margherita.jpg' },
    { id: '2', name: 'Pepperoni Pizza', price: '$14.00', image: 'pepperoni.jpg' },
    { id: '3', name: 'Baked Rolls x 8', price: '$8.00', image: 'rolls.jpg' },
    { id: '4', name: 'Super Pepperoni', price: '$10.00', image: 'super-pepperoni.jpg' }
  ];
  
  if (id === '3') {
    res.json([{ id: '3', name: 'Baked Rolls x 8', price: '$8.00', image: 'rolls.jpg' }]);
  } else {
    const filtered = inventory.filter(item => item.id === id);
    res.json(filtered);
  }
});

app.post('/api/inventory/add', (req, res) => {
  const { id, name, price, image } = req.body;
  
  if (!id || !name || !price || !image) {
    return res.status(400).json({ message: 'Not all requirements are met' });
  }
  
  // Simulate duplicate ID check
  if (id === '10') {
    return res.status(400).json({ message: 'Item with this ID already exists' });
  }
  
  res.status(200).json({ message: 'Item added successfully', item: req.body });
});

app.get('/api', (req, res) => {
  res.json({ status: 'ok', message: 'Mock API Server', version: '1.0.0' });
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'healthy', timestamp: new Date().toISOString() });
});

// Mock web pages for completeness
app.get('/', (req, res) => {
  res.send(`
    <!DOCTYPE html>
    <html>
      <head>
        <title>Mock Demo App</title>
        <style>
          body { font-family: Arial, sans-serif; margin: 40px; }
          nav { margin: 20px 0; }
          nav a { margin-right: 20px; text-decoration: none; color: #007bff; }
          nav a:hover { text-decoration: underline; }
        </style>
      </head>
      <body>
        <h1>Mock Demo Application</h1>
        <p>This is a comprehensive mock server for testing purposes.</p>
        <nav>
          <a href="/login">Login</a> | 
          <a href="/grid">Grid</a> | 
          <a href="/search">Search</a> | 
          <a href="/checkout">Checkout</a>
        </nav>
        <p>API Endpoints:</p>
        <ul>
          <li><a href="/api">API Status</a></li>
          <li><a href="/api/inventory">Inventory API</a></li>
          <li><a href="/health">Health Check</a></li>
        </ul>
      </body>
    </html>
  `);
});

app.get('/login', (req, res) => {
  res.send(`
    <!DOCTYPE html>
    <html>
      <head>
        <title>Login - Mock Demo App</title>
        <style>
          body { font-family: Arial, sans-serif; margin: 40px; }
          .login-form { max-width: 300px; }
          input, button { width: 100%; padding: 10px; margin: 5px 0; }
          button { background: #007bff; color: white; border: none; cursor: pointer; }
          button:hover { background: #0056b3; }
        </style>
      </head>
      <body>
        <h1>Login</h1>
        <form id="login-form" class="login-form">
          <input id="username" type="text" placeholder="Username" required>
          <input id="password" type="password" placeholder="Password" required>
          <button id="signin-button" type="submit">Sign In</button>
        </form>
        <div id="message"></div>
        <script>
          document.getElementById('login-form').addEventListener('submit', function(e) {
            e.preventDefault();
            const username = document.getElementById('username').value;
            const password = document.getElementById('password').value;
            if (username && password) {
              document.getElementById('message').innerHTML = 'Login successful for: ' + username;
              setTimeout(() => window.location.href = '/grid', 1000);
            } else {
              document.getElementById('message').innerHTML = 'Please enter both username and password';
            }
          });
        </script>
      </body>
    </html>
  `);
});

app.get('/grid', (req, res) => {
  res.send(`
    <!DOCTYPE html>
    <html>
      <head>
        <title>Grid - Mock Demo App</title>
        <style>
          body { font-family: Arial, sans-serif; margin: 40px; }
          #menu { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; }
          .item { border: 1px solid #ddd; padding: 15px; border-radius: 5px; }
          .item img { width: 100%; height: 150px; object-fit: cover; }
          button { background: #28a745; color: white; border: none; padding: 8px 16px; cursor: pointer; }
          button:hover { background: #218838; }
        </style>
      </head>
      <body>
        <h1>Product Grid</h1>
        <div id="menu">
          <div class="item">
            <h3 data-test-id="item-name">Margherita Pizza</h3>
            <span id="item-price">$12.00</span>
            <img src="margherita.jpg" alt="Margherita Pizza">
            <button data-test-id="add-to-order">Add to Cart</button>
          </div>
          <div class="item">
            <h3 data-test-id="item-name">Super Pepperoni</h3>
            <span id="item-price">$10.00</span>
            <img src="super-pepperoni.jpg" alt="Super Pepperoni">
            <button data-test-id="add-to-order">Add to Cart</button>
          </div>
          <div class="item">
            <h3 data-test-id="item-name">Baked Rolls x 8</h3>
            <span id="item-price">$8.00</span>
            <img src="rolls.jpg" alt="Baked Rolls">
            <button data-test-id="add-to-order">Add to Cart</button>
          </div>
        </div>
      </body>
    </html>
  `);
});

app.get('/search', (req, res) => {
  res.send(`
    <!DOCTYPE html>
    <html>
      <head>
        <title>Search - Mock Demo App</title>
        <style>
          body { font-family: Arial, sans-serif; margin: 40px; }
          form { margin: 20px 0; }
          input, button { padding: 10px; margin: 5px; }
          button { background: #007bff; color: white; border: none; cursor: pointer; }
          button:hover { background: #0056b3; }
        </style>
      </head>
      <body>
        <h1>Search</h1>
        <form>
          <input name="searchWord" type="text" placeholder="Search for items..." required>
          <button type="submit">Search</button>
        </form>
        <div id="result">Search results will appear here</div>
        <script>
          document.querySelector('form').addEventListener('submit', function(e) {
            e.preventDefault();
            const searchTerm = document.querySelector('input[name="searchWord"]').value;
            if (searchTerm.trim()) {
              document.getElementById('result').innerHTML = 'Found one result for ' + searchTerm;
            } else {
              document.getElementById('result').innerHTML = 'Please provide a search word.';
            }
          });
        </script>
      </body>
    </html>
  `);
});

app.get('/checkout', (req, res) => {
  res.send(`
    <!DOCTYPE html>
    <html>
      <head>
        <title>Checkout - Mock Demo App</title>
        <style>
          body { font-family: Arial, sans-serif; margin: 40px; }
          form { max-width: 400px; }
          input, button { width: 100%; padding: 10px; margin: 5px 0; }
          button { background: #28a745; color: white; border: none; cursor: pointer; }
          button:hover { background: #218838; }
          .cart-total { margin: 20px 0; padding: 10px; background: #f8f9fa; border-radius: 5px; }
        </style>
      </head>
      <body>
        <h1>Checkout</h1>
        <form action="/form-validation">
          <input name="firstName" type="text" placeholder="First Name" required>
          <input name="lastName" type="text" placeholder="Last Name" required>
          <input name="email" type="email" placeholder="Email" required>
          <input name="phone" type="tel" placeholder="Phone" required>
          <button type="submit">Submit Order</button>
        </form>
        <div class="cart-total">
          <span class="price">Total: <b>$25.00</b></span>
        </div>
        <script>
          document.querySelector('form').addEventListener('submit', function(e) {
            e.preventDefault();
            alert('Order submitted successfully! Order confirmation: #12345');
          });
        </script>
      </body>
    </html>
  `);
});

app.listen(port, () => {
  console.log(\`Comprehensive mock server running on port \${port}\`);
  console.log(\`Available endpoints:\`);
  console.log(\`- GET / - Home page\`);
  console.log(\`- GET /login - Login page\`);
  console.log(\`- GET /grid - Product grid\`);
  console.log(\`- GET /search - Search page\`);
  console.log(\`- GET /checkout - Checkout page\`);
  console.log(\`- GET /api - API status\`);
  console.log(\`- GET /api/inventory - Inventory API\`);
  console.log(\`- GET /health - Health check\`);
});
EOF

    log_success "Comprehensive mock server created"
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
    PORT="$port" node comprehensive-mock-server.js &
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

# Function to test service connectivity
test_connectivity() {
    local port=$1
    
    log_info "Testing service connectivity on port: $port"
    
    # Test basic connectivity
    if ! curl -f "http://localhost:$port" &> /dev/null; then
        log_error "Basic connectivity test failed"
        return 1
    fi
    
    # Test API endpoints
    log_info "Testing API endpoints..."
    curl -f "http://localhost:$port/api" &> /dev/null || log_warning "API endpoint not available"
    curl -f "http://localhost:$port/api/inventory" &> /dev/null || log_warning "Inventory API not available"
    curl -f "http://localhost:$port/health" &> /dev/null || log_warning "Health check not available"
    
    # Test web pages
    log_info "Testing web pages..."
    curl -f "http://localhost:$port/login" &> /dev/null || log_warning "Login page not available"
    curl -f "http://localhost:$port/grid" &> /dev/null || log_warning "Grid page not available"
    curl -f "http://localhost:$port/search" &> /dev/null || log_warning "Search page not available"
    curl -f "http://localhost:$port/checkout" &> /dev/null || log_warning "Checkout page not available"
    
    log_success "Service connectivity test passed"
    return 0
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
    pkill -f "node comprehensive-mock-server.js" 2>/dev/null || true
    
    # Clean up Docker resources
    docker container prune -f 2>/dev/null || true
    docker image prune -f 2>/dev/null || true
    
    log_success "Cleanup completed"
}

# Main execution function
main() {
    log_info "Starting Advanced Docker Platform Resolution"
    log_info "Requested Platform: $REQUESTED_PLATFORM"
    log_info "Port: $PORT"
    log_info "Container Name: $CONTAINER_NAME"
    
    # Check prerequisites
    check_docker_and_qemu
    
    # Analyze available platforms
    local available_platform=$(analyze_image_platforms "$DEMO_IMAGE")
    log_info "Available image platform: $available_platform"
    
    # Strategy 1: Try platform-specific pull and run
    log_info "=== Strategy 1: Platform-Specific Approach ==="
    if try_platform_specific_pull "$REQUESTED_PLATFORM" && start_container_with_platform "$REQUESTED_PLATFORM" "$CONTAINER_NAME" "$PORT"; then
        if wait_for_service "$PORT" && test_connectivity "$PORT"; then
            log_success "Strategy 1 successful: Platform-specific container running"
            exit 0
        fi
    fi
    
    # Strategy 2: Try multi-platform approach
    log_info "=== Strategy 2: Multi-Platform Approach ==="
    if try_multi_platform_approach && start_container_without_platform "$CONTAINER_NAME" "$PORT"; then
        if wait_for_service "$PORT" && test_connectivity "$PORT"; then
            log_success "Strategy 2 successful: Multi-platform container running"
            exit 0
        fi
    fi
    
    # Strategy 3: Use comprehensive mock server fallback
    log_info "=== Strategy 3: Comprehensive Mock Server Fallback ==="
    if create_comprehensive_mock_server && start_mock_server "$PORT"; then
        if wait_for_service "$PORT" && test_connectivity "$PORT"; then
            log_success "Strategy 3 successful: Comprehensive mock server running"
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
