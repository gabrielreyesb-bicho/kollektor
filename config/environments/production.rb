require "active_support/core_ext/integer/time"

Kollektor::Application.configure do
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true
  
  # Asset handling
  config.public_file_server.enabled = true
  config.assets.compile = true
  config.assets.digest = true
  
  # Active Storage
  config.active_storage.service = :amazon
  config.active_storage.replace_on_assign_to_many = false
  
  # Set the host for URL generation
  Rails.application.routes.default_url_options[:host] = 'kollektor-611834243c86.herokuapp.com'
  config.action_controller.default_url_options = { host: 'kollektor-611834243c86.herokuapp.com' }
  
  # Force SSL
  config.force_ssl = true
  
  # Active Storage URL generation
  config.active_storage.resolve_model_to_route = :rails_storage_proxy
  config.active_storage.default_url_options = { host: 'kollektor-611834243c86.herokuapp.com', protocol: 'https' }

  config.logger = ActiveSupport::Logger.new(STDOUT)
    .tap  { |logger| logger.formatter = ::Logger::Formatter.new }
    .then { |logger| ActiveSupport::TaggedLogging.new(logger) }

  config.log_tags = [ :request_id ]
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")
  config.action_mailer.perform_caching = false
  config.i18n.fallbacks = true
  config.active_support.report_deprecations = false
  config.active_record.dump_schema_after_migration = false
end
