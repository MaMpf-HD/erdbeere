Sidekiq.configure_client do |config|
  Sidekiq::Status.configure_client_middleware config, expiration: 30.minutes.to_i
end

Sidekiq.configure_server do |config|
  Sidekiq::Status.configure_client_middleware config, expiration: 30.minutes.to_i
end