require Rails.root.join('app', 'workers', 'cache_populator')
# see https://stackoverflow.com/questions/17837923/queue-sidekiq-job-on-rails-app-start
Rails.application.config.after_initialize do
  all_jobs = Sidekiq::ScheduledSet.new
  # If this is true, CachePopulator is already scheduled - don't start it again
  unless all_jobs.map(&:klass).include?("CachePopulator")
    puts "########### InitCachePopulation ##############"
    # give rails time to build before running this job & keeps this initialization from re-running
    CachePopulator.perform_in(1.minute)
    # your code here
  end
 end