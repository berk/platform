namespace :platform do
  desc "Sync config and db migrations for tr8n plugin."
  task :sync do
    system "rsync -ruv vendor/plugins/platform/config/platform ./config"
    system "rsync -ruv vendor/plugins/platform/db/migrate ./db"
  end

  desc "Sync db migrations for tr8n plugin."
  task :sync_db do
    system "rsync -ruv vendor/plugins/platform/db/migrate ./db"
  end
  
  desc "Initializes all of the tables with default data"
  task :init => :environment do
    raise "This action is prohibited in this environment" if ['production', 'stage', 'staging'].include?(Rails.env) and env('force') != 'true'
    Platform::Config.reset_all!
  end
  
end