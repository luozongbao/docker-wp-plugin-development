#!/bin/bash

# WordPress Development Environment Management Script

set -e

COMPOSE_FILE="docker-compose.yml"
WP_URL="http://localhost:8080"
WP_ADMIN_URL="http://localhost:8080/wp-admin"
PHPMYADMIN_URL="http://localhost:8081"
MAILHOG_URL="http://localhost:8025"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_color() {
    printf "${1}${2}${NC}\n"
}

# Check if Docker and Docker Compose are installed
check_requirements() {
    if ! command -v docker &> /dev/null; then
        print_color $RED "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    if ! docker compose version &> /dev/null; then
        print_color $RED "Docker Compose is not available. Please install Docker with Compose plugin."
        exit 1
    fi
}

# Start the development environment
start() {
    print_color $BLUE "Starting WordPress development environment..."
    docker compose up -d
    
    print_color $GREEN "Environment started successfully!"
    print_status
}

# Stop the development environment
stop() {
    print_color $BLUE "Stopping WordPress development environment..."
    docker compose down
    print_color $GREEN "Environment stopped successfully!"
}

# Restart the environment
restart() {
    print_color $BLUE "Restarting WordPress development environment..."
    docker compose restart
    print_color $GREEN "Environment restarted successfully!"
    print_status
}

# Show environment status
status() {
    print_color $BLUE "Checking environment status..."
    docker compose ps
}

# Print access information
print_status() {
    echo ""
    print_color $GREEN "🚀 WordPress Development Environment is running!"
    echo ""
    print_color $YELLOW "Access URLs:"
    echo "  WordPress Site: $WP_URL"
    echo "  WordPress Admin: $WP_ADMIN_URL"
    echo "  phpMyAdmin: $PHPMYADMIN_URL"
    echo "  MailHog: $MAILHOG_URL"
    echo ""
    print_color $YELLOW "Database Credentials:"
    echo "  Host: localhost:3306"
    echo "  Database: wordpress_db"
    echo "  Username: wordpress"
    echo "  Password: wordpress_password"
    echo "  Root Password: root_password"
    echo ""
}

# Show logs
logs() {
    if [ -z "$2" ]; then
        docker compose logs -f
    else
        docker compose logs -f "$2"
    fi
}

# Execute WP-CLI commands
wp_cli() {
    shift # Remove 'wp' from arguments
    docker compose exec wpcli wp "$@"
}

# Create a new plugin template
create_plugin() {
    if [ -z "$2" ]; then
        print_color $RED "Please provide a plugin name: ./dev.sh create-plugin my-plugin-name"
        exit 1
    fi
    
    PLUGIN_NAME="$2"
    PLUGIN_DIR="plugins/$PLUGIN_NAME"
    
    if [ -d "$PLUGIN_DIR" ]; then
        print_color $RED "Plugin directory '$PLUGIN_DIR' already exists!"
        exit 1
    fi
    
    print_color $BLUE "Creating plugin: $PLUGIN_NAME"
    mkdir -p "$PLUGIN_DIR"
    
    # Create main plugin file
    cat > "$PLUGIN_DIR/$PLUGIN_NAME.php" << EOF
<?php
/**
 * Plugin Name: $(echo $PLUGIN_NAME | sed 's/-/ /g' | sed 's/\b\w/\U&/g')
 * Plugin URI: https://example.com
 * Description: A custom WordPress plugin for development.
 * Version: 1.0.0
 * Author: Your Name
 * Author URI: https://example.com
 * License: GPL v2 or later
 * Text Domain: $PLUGIN_NAME
 */

// Prevent direct access
if (!defined('ABSPATH')) {
    exit;
}

// Define plugin constants
define('$(echo $PLUGIN_NAME | tr '[:lower:]' '[:upper:]' | tr '-' '_')_VERSION', '1.0.0');
define('$(echo $PLUGIN_NAME | tr '[:lower:]' '[:upper:]' | tr '-' '_')_PLUGIN_DIR', plugin_dir_path(__FILE__));
define('$(echo $PLUGIN_NAME | tr '[:lower:]' '[:upper:]' | tr '-' '_')_PLUGIN_URL', plugin_dir_url(__FILE__));

/**
 * Main plugin class
 */
class $(echo $PLUGIN_NAME | sed 's/-/_/g' | sed 's/\b\w/\U&/g') {
    
    /**
     * Constructor
     */
    public function __construct() {
        add_action('init', array(\$this, 'init'));
        register_activation_hook(__FILE__, array(\$this, 'activate'));
        register_deactivation_hook(__FILE__, array(\$this, 'deactivate'));
    }
    
    /**
     * Initialize plugin
     */
    public function init() {
        // Add your initialization code here
        add_action('wp_enqueue_scripts', array(\$this, 'enqueue_scripts'));
    }
    
    /**
     * Enqueue scripts and styles
     */
    public function enqueue_scripts() {
        wp_enqueue_style(
            '$PLUGIN_NAME-style',
            $(echo $PLUGIN_NAME | tr '[:lower:]' '[:upper:]' | tr '-' '_')_PLUGIN_URL . 'assets/css/style.css',
            array(),
            $(echo $PLUGIN_NAME | tr '[:lower:]' '[:upper:]' | tr '-' '_')_VERSION
        );
        
        wp_enqueue_script(
            '$PLUGIN_NAME-script',
            $(echo $PLUGIN_NAME | tr '[:lower:]' '[:upper:]' | tr '-' '_')_PLUGIN_URL . 'assets/js/script.js',
            array('jquery'),
            $(echo $PLUGIN_NAME | tr '[:lower:]' '[:upper:]' | tr '-' '_')_VERSION,
            true
        );
    }
    
    /**
     * Plugin activation
     */
    public function activate() {
        // Add activation code here
        flush_rewrite_rules();
    }
    
    /**
     * Plugin deactivation
     */
    public function deactivate() {
        // Add deactivation code here
        flush_rewrite_rules();
    }
}

// Initialize the plugin
new $(echo $PLUGIN_NAME | sed 's/-/_/g' | sed 's/\b\w/\U&/g')();
EOF
    
    # Create assets directories
    mkdir -p "$PLUGIN_DIR/assets/css"
    mkdir -p "$PLUGIN_DIR/assets/js"
    mkdir -p "$PLUGIN_DIR/includes"
    mkdir -p "$PLUGIN_DIR/templates"
    
    # Create basic CSS file
    cat > "$PLUGIN_DIR/assets/css/style.css" << EOF
/**
 * $(echo $PLUGIN_NAME | sed 's/-/ /g' | sed 's/\b\w/\U&/g') Styles
 */

.${PLUGIN_NAME}-container {
    /* Add your styles here */
}
EOF
    
    # Create basic JS file
    cat > "$PLUGIN_DIR/assets/js/script.js" << EOF
/**
 * $(echo $PLUGIN_NAME | sed 's/-/ /g' | sed 's/\b\w/\U&/g') JavaScript
 */

(function($) {
    'use strict';
    
    $(document).ready(function() {
        // Add your JavaScript code here
    });
    
})(jQuery);
EOF
    
    # Create README
    cat > "$PLUGIN_DIR/README.md" << EOF
# $(echo $PLUGIN_NAME | sed 's/-/ /g' | sed 's/\b\w/\U&/g')

A custom WordPress plugin for development.

## Description

Add your plugin description here.

## Installation

1. Upload the plugin to your WordPress plugins directory
2. Activate the plugin through the WordPress admin

## Usage

Add usage instructions here.

## Development

This plugin was created using the WordPress development environment.
EOF
    
    print_color $GREEN "Plugin '$PLUGIN_NAME' created successfully in $PLUGIN_DIR"
    print_color $YELLOW "You can now activate it in WordPress admin or use WP-CLI:"
    print_color $BLUE "  ./dev.sh wp plugin activate $PLUGIN_NAME"
}

# Backup database
backup_db() {
    BACKUP_FILE="backup-$(date +%Y%m%d-%H%M%S).sql"
    print_color $BLUE "Creating database backup: $BACKUP_FILE"
    docker compose exec db mysqldump -u root -proot_password wordpress_db > "$BACKUP_FILE"
    print_color $GREEN "Database backup created: $BACKUP_FILE"
}

# Restore database
restore_db() {
    if [ -z "$2" ]; then
        print_color $RED "Please provide backup file: ./dev.sh restore-db backup.sql"
        exit 1
    fi
    
    if [ ! -f "$2" ]; then
        print_color $RED "Backup file '$2' not found!"
        exit 1
    fi
    
    print_color $BLUE "Restoring database from: $2"
    docker compose exec -T db mysql -u root -proot_password wordpress_db < "$2"
    print_color $GREEN "Database restored successfully!"
}

# Clean up environment
clean() {
    print_color $YELLOW "This will remove all containers, volumes, and data. Are you sure? (y/N)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        print_color $BLUE "Cleaning up environment..."
        docker compose down -v --remove-orphans
        docker system prune -f
        print_color $GREEN "Environment cleaned successfully!"
    else
        print_color $BLUE "Clean up cancelled."
    fi
}

# Show help
help() {
    echo "WordPress Development Environment Manager"
    echo ""
    echo "Usage: ./dev.sh [command] [options]"
    echo ""
    echo "Commands:"
    echo "  start              Start the development environment"
    echo "  stop               Stop the development environment"
    echo "  restart            Restart the development environment"
    echo "  status             Show environment status"
    echo "  logs [service]     Show logs (optionally for specific service)"
    echo "  wp [command]       Execute WP-CLI commands"
    echo "  create-plugin <name>  Create a new plugin template"
    echo "  backup-db          Create database backup"
    echo "  restore-db <file>  Restore database from backup"
    echo "  clean              Clean up environment (removes all data)"
    echo "  help               Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./dev.sh start"
    echo "  ./dev.sh wp plugin list"
    echo "  ./dev.sh create-plugin my-awesome-plugin"
    echo "  ./dev.sh logs wordpress"
    echo ""
}

# Main script logic
main() {
    check_requirements
    
    case "${1:-help}" in
        start)
            start
            ;;
        stop)
            stop
            ;;
        restart)
            restart
            ;;
        status)
            status
            ;;
        logs)
            logs "$@"
            ;;
        wp)
            wp_cli "$@"
            ;;
        create-plugin)
            create_plugin "$@"
            ;;
        backup-db)
            backup_db
            ;;
        restore-db)
            restore_db "$@"
            ;;
        clean)
            clean
            ;;
        help|--help|-h)
            help
            ;;
        *)
            print_color $RED "Unknown command: $1"
            echo ""
            help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
