#!/bin/bash

# Quick Start Script for WordPress Development Environment

echo "🚀 WordPress Plugin Development Environment"
echo "==========================================="
echo ""

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

echo "✅ Docker is running"
echo ""

# Start the environment
echo "🔄 Starting WordPress development environment..."
docker-compose up -d

# Wait for services to be ready
echo "⏳ Waiting for services to start..."
sleep 10

# Check if WordPress is accessible
if curl -s http://localhost:8080 >/dev/null; then
    echo ""
    echo "🎉 Environment is ready!"
    echo ""
    echo "📝 Access Information:"
    echo "   WordPress Site: http://localhost:8080"
    echo "   WordPress Admin: http://localhost:8080/wp-admin"
    echo "   phpMyAdmin: http://localhost:8081"
    echo "   MailHog: http://localhost:8025"
    echo ""
    echo "🔑 Database Credentials:"
    echo "   Host: localhost:3306"
    echo "   Database: wordpress_db"
    echo "   Username: wordpress"
    echo "   Password: wordpress_password"
    echo ""
    echo "🛠️  Useful Commands:"
    echo "   Stop environment: docker-compose down"
    echo "   View logs: docker-compose logs -f"
    echo "   Use dev script: ./scripts/dev.sh help"
    echo ""
    echo "📁 Your plugin files go in: ./plugins/"
    echo "📁 Your theme files go in: ./themes/"
    echo ""
else
    echo "❌ WordPress is not responding. Check the logs:"
    echo "   docker-compose logs wordpress"
fi
