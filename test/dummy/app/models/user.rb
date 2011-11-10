class User < ActiveRecord::Base
  
  has_one :admin
  has_many :bookmarks
  
  def guest?
    id.blank?
  end
  
  def admin?
    return true if Rails.env == 'development'
    not admin.nil? 
  end
  
  def name
    [first_name, last_name].join(" ")
  end
  
  def gender
    super || 'unknown'
  end
  
  def make_admin!
    return if admin?
    
    Admin.create(:user => self, :level => 0)
  end
  
  def to_s
    name
  end
  
  def mugshot
    default_url = "http://#{Platform::Config.site_base_url}#{Platform::Config.silhouette_image}"
    pp default_url
    return default_url
    gravatar_id = Digest::MD5.hexdigest(email.downcase)
    "http://gravatar.com/avatar/#{gravatar_id}.png?s=48&d=#{CGI.escape(default_url)}"
  end    
  
end
