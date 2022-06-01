require 'sidekiq/web'

redis_conn = proc {
  RedisHandler.redis_instance
}

Sidekiq.configure_client do |config|
  config.redis = ConnectionPool.new(size: ENV.fetch('SIDEKIQ_CLIENT_CONNECTION_POOL', 5).to_i, &redis_conn)
end

Sidekiq.configure_server do |config|
  config.redis = ConnectionPool.new(size: ENV.fetch('SIDEKIQ_SERVER_CONNECTION_POOL', 30).to_i, &redis_conn)
end
