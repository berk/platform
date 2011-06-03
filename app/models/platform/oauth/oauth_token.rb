class Platform::Oauth::OauthToken < ActiveRecord::Base
  set_table_name :platform_oauth_tokens
  
#  record_cache :by => :id
#  record_cache :id, :by => :user_id
# can't do this because oauth-plugin/../ApplicationControllerMethods#verify_oauth_signture barfs
#  record_cache :id, :by => :token

  belongs_to :application, :class_name => "Platform::Application"
  belongs_to :user

  validates_uniqueness_of :token
  validates_presence_of   :application, :token

  before_validation :generate_keys, :on => :create

  def invalidated?
    invalidate! if valid_to && invalidated_at.nil? && Time.now > valid_to

    invalidated_at.try(:<=, Time.now)
  end

  def invalidate!
    update_attribute(:invalidated_at, Time.now)
  end

  def authorized?
    authorized_at && !invalidated?
  end

  def to_query
    "oauth_token=#{token}&oauth_token_secret=#{secret}"
  end

protected

  def generate_keys
    self.token = OAuth::Helper.generate_key(40)[0,40]
    self.secret = OAuth::Helper.generate_key(40)[0,40]
  end

end
