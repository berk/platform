Rails.application.routes.draw do
  mount Tr8n::Engine => "/tr8n"
  mount WillFilter::Engine => "/will_filter"
  mount Platform::Engine => "/platform"

  ##################################################
  # API Routes
  ##################################################
  match "/api", :to => "api/users#index"
  match "/api/user", :to => "api/users#index"
  match "/api/user/bookmarks", :to => "api/users#bookmarks"
  match "/api/bookmark/create", :to => "api/bookmarks#create"
  match "/api/bookmark/delete/:id", :to => "api/bookmarks#delete"
  match "/api/bookmark/update/:id", :to => "api/bookmarks#update"
  match "/api/bookmark(/:id)", :to => "api/bookmarks#index"
  
  # Enable Platform API
  [:applications, :platform].each do |ctrl|
    match "api/#{ctrl}(/:action)", :controller => "platform/api/#{ctrl}"
  end
  ##################################################

  root :to => "home#index"

  [:admins, :users, :bookmarks].each do |ctrl|
    match "/admin/#{ctrl}(/:action)", :controller => "admin/#{ctrl}"
  end

  namespace :admin do
    root :to => "users#index"
  end

  match ':controller(/:action(/:id(.:format)))'
end

