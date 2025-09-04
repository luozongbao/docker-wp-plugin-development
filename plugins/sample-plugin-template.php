<?php
/**
 * Sample Plugin Template
 * 
 * This is a template file showing the basic structure of a WordPress plugin.
 * Copy this to create new plugins in the plugins directory.
 */

/**
 * Plugin Name: Sample Plugin Template
 * Plugin URI: https://example.com
 * Description: This is a sample plugin template for WordPress development.
 * Version: 1.0.0
 * Author: Developer Name
 * Author URI: https://example.com
 * License: GPL v2 or later
 * License URI: https://www.gnu.org/licenses/gpl-2.0.html
 * Text Domain: sample-plugin
 * Domain Path: /languages
 */

// Prevent direct access
if (!defined('ABSPATH')) {
    exit;
}

// Plugin constants
define('SAMPLE_PLUGIN_VERSION', '1.0.0');
define('SAMPLE_PLUGIN_PLUGIN_DIR', plugin_dir_path(__FILE__));
define('SAMPLE_PLUGIN_PLUGIN_URL', plugin_dir_url(__FILE__));

/**
 * Main Plugin Class
 */
class SamplePlugin {
    
    /**
     * Constructor
     */
    public function __construct() {
        add_action('init', array($this, 'init'));
        add_action('admin_init', array($this, 'admin_init'));
        
        register_activation_hook(__FILE__, array($this, 'activate'));
        register_deactivation_hook(__FILE__, array($this, 'deactivate'));
        register_uninstall_hook(__FILE__, array($this, 'uninstall'));
    }
    
    /**
     * Initialize plugin
     */
    public function init() {
        // Load text domain for translations
        load_plugin_textdomain('sample-plugin', false, dirname(plugin_basename(__FILE__)) . '/languages/');
        
        // Add actions and filters
        add_action('wp_enqueue_scripts', array($this, 'enqueue_scripts'));
        add_action('admin_enqueue_scripts', array($this, 'admin_enqueue_scripts'));
        add_action('wp_head', array($this, 'add_meta_tags'));
        
        // Add shortcodes
        add_shortcode('sample_shortcode', array($this, 'sample_shortcode'));
        
        // Add AJAX handlers
        add_action('wp_ajax_sample_action', array($this, 'handle_ajax_request'));
        add_action('wp_ajax_nopriv_sample_action', array($this, 'handle_ajax_request'));
    }
    
    /**
     * Initialize admin-specific functionality
     */
    public function admin_init() {
        // Add admin menu
        add_action('admin_menu', array($this, 'add_admin_menu'));
        
        // Add settings
        add_action('admin_init', array($this, 'register_settings'));
    }
    
    /**
     * Enqueue frontend scripts and styles
     */
    public function enqueue_scripts() {
        wp_enqueue_style(
            'sample-plugin-style',
            SAMPLE_PLUGIN_PLUGIN_URL . 'assets/css/style.css',
            array(),
            SAMPLE_PLUGIN_VERSION
        );
        
        wp_enqueue_script(
            'sample-plugin-script',
            SAMPLE_PLUGIN_PLUGIN_URL . 'assets/js/script.js',
            array('jquery'),
            SAMPLE_PLUGIN_VERSION,
            true
        );
        
        // Localize script for AJAX
        wp_localize_script('sample-plugin-script', 'samplePlugin', array(
            'ajaxurl' => admin_url('admin-ajax.php'),
            'nonce' => wp_create_nonce('sample_plugin_nonce'),
            'strings' => array(
                'loading' => __('Loading...', 'sample-plugin'),
                'error' => __('An error occurred', 'sample-plugin')
            )
        ));
    }
    
    /**
     * Enqueue admin scripts and styles
     */
    public function admin_enqueue_scripts($hook) {
        // Only load on plugin pages
        if (strpos($hook, 'sample-plugin') === false) {
            return;
        }
        
        wp_enqueue_style(
            'sample-plugin-admin-style',
            SAMPLE_PLUGIN_PLUGIN_URL . 'assets/css/admin.css',
            array(),
            SAMPLE_PLUGIN_VERSION
        );
        
        wp_enqueue_script(
            'sample-plugin-admin-script',
            SAMPLE_PLUGIN_PLUGIN_URL . 'assets/js/admin.js',
            array('jquery'),
            SAMPLE_PLUGIN_VERSION,
            true
        );
    }
    
    /**
     * Add meta tags to head
     */
    public function add_meta_tags() {
        echo '<meta name="sample-plugin" content="' . SAMPLE_PLUGIN_VERSION . '">' . "\n";
    }
    
    /**
     * Add admin menu
     */
    public function add_admin_menu() {
        add_options_page(
            __('Sample Plugin Settings', 'sample-plugin'),
            __('Sample Plugin', 'sample-plugin'),
            'manage_options',
            'sample-plugin-settings',
            array($this, 'settings_page')
        );
    }
    
    /**
     * Register plugin settings
     */
    public function register_settings() {
        register_setting('sample_plugin_settings', 'sample_plugin_option');
        
        add_settings_section(
            'sample_plugin_main_section',
            __('Main Settings', 'sample-plugin'),
            array($this, 'settings_section_callback'),
            'sample_plugin_settings'
        );
        
        add_settings_field(
            'sample_plugin_field',
            __('Sample Field', 'sample-plugin'),
            array($this, 'settings_field_callback'),
            'sample_plugin_settings',
            'sample_plugin_main_section'
        );
    }
    
    /**
     * Settings section callback
     */
    public function settings_section_callback() {
        echo '<p>' . __('Configure your sample plugin settings below.', 'sample-plugin') . '</p>';
    }
    
    /**
     * Settings field callback
     */
    public function settings_field_callback() {
        $value = get_option('sample_plugin_option', '');
        echo '<input type="text" name="sample_plugin_option" value="' . esc_attr($value) . '" />';
    }
    
    /**
     * Settings page
     */
    public function settings_page() {
        ?>
        <div class="wrap">
            <h1><?php echo esc_html(get_admin_page_title()); ?></h1>
            <form action="options.php" method="post">
                <?php
                settings_fields('sample_plugin_settings');
                do_settings_sections('sample_plugin_settings');
                submit_button();
                ?>
            </form>
        </div>
        <?php
    }
    
    /**
     * Sample shortcode
     */
    public function sample_shortcode($atts) {
        $atts = shortcode_atts(array(
            'text' => __('Hello World', 'sample-plugin'),
            'class' => 'sample-shortcode'
        ), $atts);
        
        return '<div class="' . esc_attr($atts['class']) . '">' . esc_html($atts['text']) . '</div>';
    }
    
    /**
     * Handle AJAX request
     */
    public function handle_ajax_request() {
        // Verify nonce
        if (!wp_verify_nonce($_POST['nonce'], 'sample_plugin_nonce')) {
            wp_die(__('Security check failed', 'sample-plugin'));
        }
        
        // Process the request
        $response = array(
            'success' => true,
            'message' => __('AJAX request processed successfully', 'sample-plugin')
        );
        
        wp_send_json($response);
    }
    
    /**
     * Plugin activation
     */
    public function activate() {
        // Create database tables if needed
        $this->create_tables();
        
        // Set default options
        add_option('sample_plugin_option', 'default_value');
        
        // Flush rewrite rules
        flush_rewrite_rules();
        
        // Schedule cron events if needed
        if (!wp_next_scheduled('sample_plugin_cron_hook')) {
            wp_schedule_event(time(), 'daily', 'sample_plugin_cron_hook');
        }
    }
    
    /**
     * Plugin deactivation
     */
    public function deactivate() {
        // Clear scheduled cron events
        wp_clear_scheduled_hook('sample_plugin_cron_hook');
        
        // Flush rewrite rules
        flush_rewrite_rules();
    }
    
    /**
     * Plugin uninstall
     */
    public static function uninstall() {
        // Remove options
        delete_option('sample_plugin_option');
        
        // Remove database tables if needed
        // global $wpdb;
        // $wpdb->query("DROP TABLE IF EXISTS {$wpdb->prefix}sample_plugin_table");
        
        // Clear any cached data
        wp_cache_flush();
    }
    
    /**
     * Create database tables
     */
    private function create_tables() {
        global $wpdb;
        
        $table_name = $wpdb->prefix . 'sample_plugin_table';
        
        $charset_collate = $wpdb->get_charset_collate();
        
        $sql = "CREATE TABLE $table_name (
            id mediumint(9) NOT NULL AUTO_INCREMENT,
            name tinytext NOT NULL,
            email varchar(100) NOT NULL,
            created_at datetime DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (id)
        ) $charset_collate;";
        
        require_once(ABSPATH . 'wp-admin/includes/upgrade.php');
        dbDelta($sql);
    }
}

// Initialize the plugin
new SamplePlugin();
