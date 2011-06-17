# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require 'rake/testtask'

Rake::TestTask.new do |test|
  test.pattern = 'test/**/*_test.rb'
  test.libs << 'test'
end

begin
 require 'jeweler'
 Jeweler::Tasks.new do |s|
   s.name = "platform"
   s.summary = "Application platform for Rails."
   s.email = "theiceberk@gmail.com"
   s.homepage = "http://github.com/berk/platform"
   s.description = "Application platform for Rails."
   s.authors = ["Michael Berkovich"]
 end
 Jeweler::GemcutterTasks.new
rescue LoadError
 puts "Jeweler not available. Install it with: sudo gem install jeweler"
end


require File.expand_path('../config/application', __FILE__)
require 'rake'

PlatformEngine::Application.load_tasks

