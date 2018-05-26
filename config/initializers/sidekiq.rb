redis_conn = proc {
  Redis.current # do anything you want here
}

Sidekiq.configure_server do |config|
  config.redis = ConnectionPool.new(size: 30, &redis_conn)
  config.average_scheduled_poll_interval = 1 # poll every second
end

Sidekiq.configure_client do |config|
  config.redis = ConnectionPool.new(size: 5, &redis_conn)
end
