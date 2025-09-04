# WordPress Plugin Development Environment

A complete Docker-based development environment for WordPress plugin development.

## Services Included

- **WordPress** (localhost:8080) - Latest WordPress installation
- **MySQL 8.0** (localhost:3306) - Database server
- **phpMyAdmin** (localhost:8081) - Database management interface
- **WP-CLI** - WordPress command line interface
- **MailHog** (localhost:8025) - Email testing tool

## Quick Start

1. **Start the environment:**
   ```bash
   docker-compose up -d
   ```

2. **Access WordPress:**
   - Website: http://localhost:8080
   - Admin: http://localhost:8080/wp-admin

3. **Access phpMyAdmin:**
   - URL: http://localhost:8081
   - Username: root
   - Password: root_password

4. **Access MailHog (Email testing):**
   - URL: http://localhost:8025

## Database Credentials

- **Database Name:** wordpress_db
- **Username:** wordpress
- **Password:** wordpress_password
- **Root Password:** root_password
- **Host:** localhost:3306

## Directory Structure

```
dev/
├── docker-compose.yml          # Main Docker Compose configuration
├── plugins/                    # Your custom plugins go here
├── themes/                     # Your custom themes go here
├── uploads/                    # WordPress uploads directory
├── mysql-init/                 # MySQL initialization scripts
├── scripts/                    # Utility scripts
└── wp-config-dev.php          # Development WordPress configuration
```

## Plugin Development

1. **Create a new plugin:**
   ```bash
   mkdir plugins/my-awesome-plugin
   ```

2. **Plugin files will be automatically available in WordPress at:**
   `/wp-content/plugins/custom/my-awesome-plugin/`

## Useful Commands

### Docker Operations
```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f wordpress

# Restart specific service
docker-compose restart wordpress
```

### WP-CLI Commands
```bash
# Access WP-CLI container
docker-compose exec wpcli bash

# Install WordPress (if needed)
docker-compose exec wpcli wp core install \
  --url=localhost:8080 \
  --title="Dev Site" \
  --admin_user=admin \
  --admin_password=admin123 \
  --admin_email=admin@example.com

# Activate a plugin
docker-compose exec wpcli wp plugin activate my-plugin

# List all plugins
docker-compose exec wpcli wp plugin list

# Update WordPress
docker-compose exec wpcli wp core update
```

### Database Operations
```bash
# Export database
docker-compose exec db mysqldump -u root -proot_password wordpress_db > backup.sql

# Import database
docker-compose exec -T db mysql -u root -proot_password wordpress_db < backup.sql
```

## Development Features

- **Debug Mode Enabled:** WordPress debug logging is active
- **Hot Reload:** Changes to plugins/themes are immediately reflected
- **Email Testing:** All emails are caught by MailHog
- **Database Access:** Direct MySQL access via phpMyAdmin
- **CLI Access:** Full WP-CLI functionality for automation

## Troubleshooting

### Common Issues

1. **Port conflicts:** If ports 8080, 8081, or 3306 are in use, modify the ports in docker-compose.yml

2. **Permission issues:** Run with proper permissions:
   ```bash
   sudo chown -R $USER:$USER plugins themes uploads
   ```

3. **Database connection errors:** Wait a few moments after starting for MySQL to fully initialize

4. **Plugin not showing:** Ensure your plugin has a proper header comment:
   ```php
   <?php
   /**
    * Plugin Name: My Awesome Plugin
    * Description: Description of the plugin
    * Version: 1.0.0
    * Author: Your Name
    */
   ```

## Security Note

This environment is for development only. Never use these credentials or configurations in production!
