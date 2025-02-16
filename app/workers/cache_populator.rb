# CachePopulator worker
class CachePopulator
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform
    Example.all.each do |e|
      ExampleSatisfier.perform_async(e.id)
      ExampleViolator.perform_async(e.id)
    end
  end
end




