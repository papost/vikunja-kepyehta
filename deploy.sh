#!/bin/bash

# Vikunja Deployment Script
# This script helps you deploy your customized Vikunja project

set -e

echo "🚀 Vikunja Deployment Script"
echo "=============================="

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo "📋 Checking prerequisites..."

if ! command_exists docker; then
    echo "❌ Docker is not installed. Please install Docker first."
    echo "   Run: curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh"
    exit 1
fi

# Check for Docker Compose (either standalone or plugin)
DOCKER_COMPOSE_CMD=""
if command_exists docker-compose; then
    DOCKER_COMPOSE_CMD="docker-compose"
elif docker compose version >/dev/null 2>&1; then
    DOCKER_COMPOSE_CMD="docker compose"
else
    echo "❌ Docker Compose is not available. Please install Docker Compose."
    echo "   For newer Docker: Docker Compose is included as a plugin"
    echo "   For older Docker: Install docker-compose separately"
    exit 1
fi

echo "✅ Docker and Docker Compose are available ($DOCKER_COMPOSE_CMD)"

# Check if army.svg exists
if [ ! -f "army.svg" ]; then
    echo "❌ army.svg not found! Make sure you're in the correct directory."
    exit 1
fi

echo "✅ Custom logo (army.svg) found"

# Function to deploy
deploy() {
    echo ""
    echo "🔨 Building and starting Vikunja..."
    
    # Stop any existing containers
    $DOCKER_COMPOSE_CMD down 2>/dev/null || true
    
    # Build and start
    $DOCKER_COMPOSE_CMD up --build -d
    
    echo ""
    echo "⏳ Waiting for services to start..."
    sleep 10
    
    # Check if services are running
    if $DOCKER_COMPOSE_CMD ps | grep -q "Up"; then
        echo ""
        echo "🎉 Deployment successful!"
        echo ""
        echo "📱 Access your Vikunja instance:"
        echo "   Frontend: http://localhost:8081"
        echo "   API:      http://localhost:3456"
        echo ""
        echo "🔍 To check status: $DOCKER_COMPOSE_CMD ps"
        echo "📋 To view logs:    $DOCKER_COMPOSE_CMD logs -f"
        echo "🛑 To stop:         $DOCKER_COMPOSE_CMD down"
    else
        echo ""
        echo "❌ Deployment failed. Check logs with: $DOCKER_COMPOSE_CMD logs"
        exit 1
    fi
}

# Function to create deployment package
create_package() {
    echo ""
    echo "📦 Creating deployment package..."
    
    PACKAGE_NAME="vikunja-deployment-$(date +%Y%m%d-%H%M%S).tar.gz"
    
    tar -czf "$PACKAGE_NAME" \
        --exclude=node_modules \
        --exclude=.git \
        --exclude=db \
        --exclude=frontend/dist \
        --exclude=frontend/node_modules \
        --exclude="*.tar.gz" \
        .
    
    echo "✅ Package created: $PACKAGE_NAME"
    echo ""
    echo "📤 To deploy on another machine:"
    echo "   1. Copy $PACKAGE_NAME to target machine"
    echo "   2. Extract: tar -xzf $PACKAGE_NAME"
    echo "   3. Run: ./deploy.sh"
}

# Function to show status
show_status() {
    echo ""
    echo "📊 Current Status:"
    echo "=================="
    
    if $DOCKER_COMPOSE_CMD ps 2>/dev/null | grep -q "Up"; then
        $DOCKER_COMPOSE_CMD ps
        echo ""
        echo "🌐 Services are running:"
        echo "   Frontend: http://localhost:8081"
        echo "   API:      http://localhost:3456"
    else
        echo "❌ No services are currently running"
        echo "   Run './deploy.sh' to start services"
    fi
}

# Function to stop services
stop_services() {
    echo ""
    echo "🛑 Stopping Vikunja services..."
    $DOCKER_COMPOSE_CMD down
    echo "✅ Services stopped"
}

# Function to show logs
show_logs() {
    echo ""
    echo "📋 Showing logs (Press Ctrl+C to exit)..."
    $DOCKER_COMPOSE_CMD logs -f
}

# Main menu
case "${1:-}" in
    "")
        deploy
        ;;
    "package")
        create_package
        ;;
    "status")
        show_status
        ;;
    "stop")
        stop_services
        ;;
    "logs")
        show_logs
        ;;
    "help"|"-h"|"--help")
        echo ""
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  (no args)  Deploy Vikunja (default)"
        echo "  package    Create deployment package"
        echo "  status     Show current status"
        echo "  stop       Stop all services"
        echo "  logs       Show service logs"
        echo "  help       Show this help"
        echo ""
        ;;
    *)
        echo "❌ Unknown command: $1"
        echo "   Run '$0 help' for usage information"
        exit 1
        ;;
esac
