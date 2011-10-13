require 'active_record'
require 'action_controller/railtie'
require 'action_view/railtie'

ENV['RAILS_ENV'] = 'test'

require ::File.expand_path("#{File.dirname(__FILE__)}/../test/dummy/config/environment")

# # database
# ActiveRecord::Base.configurations = {'test' => {:adapter => 'sqlite3', :database => ':memory:'}}
# ActiveRecord::Base.establish_connection('test')
# 
# # config
# app = Class.new(Rails::Application)
# app.config.secret_token = "3b7cd727ee24e8444053437c36cc66c4"
# app.config.session_store :cookie_store, :key => "_myapp_session"
# app.config.active_support.deprecation = :log
# app.initialize!
# 
# # routes
# require "#{File.dirname(__FILE__)}/../test/dummy/config/routes.rb"
# 
# # app.routes.draw do
# #   resources :users
# # end
# 
# # models
# Dir["#{File.dirname(__FILE__)}/../test/dummy/app/models/*.rb"].each do |f| 
#   if [:user, :admin].include?(f.split("/").last.gsub('.rb', '').to_sym)
#     require f 
#   end  
# end  
# 
# # controllers
# Dir["#{File.dirname(__FILE__)}/../test/dummy/app/controllers/*.rb"].each do |f| 
#   if [:user, :admin].include?(f.split("/").last.gsub('.rb', '').to_sym)
#     require f 
#   end  
# end  
# 
# # helpers
# Object.const_set(:ApplicationHelper, Module.new)

#migrations
class CreateAllTables < ActiveRecord::Migration
  def self.up
    Dir["#{File.dirname(__FILE__)}/../test/dummy/db/migrate/*.rb"].each do |f| 
      require f 
      f.split("/").last.gsub('.rb', '').split('_')[1..-1].join('_').camelcase.constantize.up
    end  
  end
end
