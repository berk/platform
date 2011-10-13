class Bookmark < ActiveRecord::Base

  has_platform_api_proxy

  belongs_to :user
  
end
