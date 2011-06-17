# Load the rails application
require File.expand_path('../application', __FILE__)
require 'pp'
gem 'will_filter'
gem 'tr8n'

Rails.configuration.after_initialize do
  
  ["../lib/core_ext/**",
   "../lib/platform",
   "../lib",
   "../app/models/platform"
  ].each do |dir|
      Dir[File.expand_path("#{File.dirname(__FILE__)}/#{dir}/*.rb")].sort.each do |file|
        pp file 
        require_or_load file
      end
  end
  
end

# Initialize the rails application
PlatformEngine::Application.initialize!
