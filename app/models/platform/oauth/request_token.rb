class Platform::Oauth::RequestToken < Platform::Oauth::OauthToken

  attr_accessor :provided_oauth_verifier

  # get rid of old tokens
  def self.sweep!
    stale_tokens.destroy_all
  end

  def self.stale_tokens
    find(:all, :conditions => ["oauth_tokens.created_at < ?", 1.day.ago])
  end

  def authorize!(user)
    return false if authorized?
    user = user.user if user.is_a?(Profile)
    self.user = user
    self.authorized_at = Time.now
    self.verifier=OAuth::Helper.generate_key(20)[0,20] unless oauth10?
    self.save
  end

  def exchange!
    return false unless authorized?
    return false unless oauth10? || verifier == provided_oauth_verifier

    RequestToken.transaction do
      access_token = AccessToken.create(:user => user, :application => application)
      invalidate!
      access_token
    end
  end

  def to_query
    if oauth10?
      super
    else
      "#{super}&oauth_callback_confirmed=true"
    end
  end

  def oob?
    'oob' == self.callback_url
  end

  def oauth10?
    (defined? OAUTH_10_SUPPORT) && OAUTH_10_SUPPORT && self.callback_url.blank?
  end

end
