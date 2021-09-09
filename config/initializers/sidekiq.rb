Sidekiq.configure_server do |config|
  config.redis = REDIS_CONFIGS
  config.average_scheduled_poll_interval = 2
end

Sidekiq.configure_client do |config|
  config.redis = REDIS_CONFIGS
end
