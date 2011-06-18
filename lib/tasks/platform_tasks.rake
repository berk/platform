namespace :platform do
  
  desc "Initializes all of the tables with default data"
  task :init => :environment do
    raise "This action is prohibited in this environment" if ['production', 'stage', 'staging'].include?(Rails.env) and env('force') != 'true'
    Platform::Config.reset_all!
  end
  
end