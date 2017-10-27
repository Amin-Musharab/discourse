Discourse::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # The test environment is used exclusively to run your application's
  # test suite.  You never need to work with it otherwise.  Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs.  Don't rely on the data there!
  config.cache_classes = true

  # Configure static asset server for tests with Cache-Control for performance
  config.public_file_server.enabled = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Print deprecation notices to the stderr
  config.active_support.deprecation = :stderr

  # lower iteration count for test
  config.pbkdf2_iterations = 10
  config.ember.variant = :development

  config.assets.compile = true
  config.assets.digest = false

  config.eager_load = false

  unless ENV['RAILS_ENABLE_TEST_LOG']
    config.logger = Logger.new(nil)
    config.log_level = :fatal
  end

  config.after_initialize do
    SiteSetting.defaults.tap do |s|
      s.set_regardless_of_locale(:s3_upload_bucket, 'bucket')
      s.set_regardless_of_locale(:min_post_length, 5)
      s.set_regardless_of_locale(:min_first_post_length, 5)
      s.set_regardless_of_locale(:min_private_message_post_length, 10)
      s.set_regardless_of_locale(:crawl_images, false)
      s.set_regardless_of_locale(:download_remote_images_to_local, false)
      s.set_regardless_of_locale(:unique_posts_mins, 0)
      s.set_regardless_of_locale(:queue_jobs, false)
      # disable plugins
      if ENV['LOAD_PLUGINS'] == '1'
        s.set_regardless_of_locale(:discourse_narrative_bot_enabled, false)
      end
    end
    SiteSetting.refresh!
  end
end
