#Rails.application.routes.draw do 
#  [:apps, :home, :login, :oauth, :forum, :ratings].each do |ctrl|
#    match "/platform/#{ctrl}(/:action)", :controller => "platform/#{ctrl}"
#  end
#
#  [:apps, :blog, :dashboard, :forum, :help, :issues, :registration, :resources].each do |ctrl|
#    match "/platform/developer/#{ctrl}(/:action)", :controller => "platform/developer/#{ctrl}"
#  end
#
#  [:apps, :categories, :developers].each do |ctrl|
#    match "/platform/admin/#{ctrl}(/:action)", :controller => "platform/admin/#{ctrl}"
#  end
#  
##  [:language, :translation, :translator].each do |ctrl|
##    match "/tr8n/api/v1/#{ctrl}(/:action)", :controller => "tr8n/api/v1/#{ctrl}"
##  end
#
#  namespace :platform do
#    root :to => "home#index"
#    namespace :developer do
#      root :to => "dashboard#index"
#    end
#    namespace :admin do
#      root :to => "apps#index"
#    end
#  end
#
#  root :to => "platform/home#index"
#end
