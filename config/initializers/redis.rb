REDIS_CONFIGS = {
  host:            ENV['REDIS_HOST'],
  password:        ENV['REDIS_PASSWORD'],
  port:            ENV['REDIS_PORT'],
  db:              ENV['REDIS_DB'],
  connect_timeout: ENV['REDIS_CONNECT_TIMEOUT']
}.delete_if { |_k, v| v.blank? }

REDIS_POOL_SIZE = Integer((Sidekiq.server? ? ENV['SIDEKIQ_CONCURRENCY'] : ENV['RAILS_MAX_THREADS']) || 1)

REDIS_POOL = ConnectionPool.new(size: REDIS_POOL_SIZE){ Redis.new(REDIS_CONFIGS) }
