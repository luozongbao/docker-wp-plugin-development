<?php
/**
 * Development WordPress Configuration
 * 
 * This file contains additional configuration for development environment
 */

// Enable all debugging
define('WP_DEBUG', true);
define('WP_DEBUG_LOG', true);
define('WP_DEBUG_DISPLAY', false);
define('SCRIPT_DEBUG', true);
define('SAVEQUERIES', true);

// Increase memory limit for development
ini_set('memory_limit', '512M');

// Disable file editing in admin
define('DISALLOW_FILE_EDIT', false);

// Enable WordPress auto-updates
define('WP_AUTO_UPDATE_CORE', true);

// Configure email for MailHog
define('WPMS_ON', true);
define('WPMS_SMTP_HOST', 'mailhog');
define('WPMS_SMTP_PORT', 1025);
define('WPMS_SMTP_AUTH', false);

// Development specific settings
define('WP_ENVIRONMENT_TYPE', 'development');
define('WP_DEVELOPMENT_MODE', 'plugin');

// Increase max execution time
ini_set('max_execution_time', 300);

// Enable error reporting
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Custom uploads directory
define('UPLOADS', 'wp-content/uploads');
